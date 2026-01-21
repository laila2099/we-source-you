// functions/src/payment_processor.js
const admin = require('firebase-admin');
const db = admin.firestore();

const DAY_MS = 24 * 60 * 60 * 1000;

const { computeFeeRate, computeFees } = require('./fees');


function toNumber(v) {
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

/**
 * Idempotent payment apply:
 * - writes/merges payments/{paymentId}
 * - if already processed => no-op
 * - then applies business logic by context
 */
async function applyPaymentSucceeded({
  provider,      // 'stripe' | 'paypal'
  context,       // 'jobContract' | 'mediaMarket' | 'hireMe'
  referenceId,   // contractId OR itemId
  paymentId,     // paymentIntentId / checkoutSessionId / paypalOrderId
  payerId,
  amount,        // number in major currency (e.g., 20.0)
  currency,      // 'EUR'
}) {
  if (!provider || !context || !referenceId || !paymentId) {
    throw new Error('applyPaymentSucceeded missing required fields');
  }

  const paymentRef = db.collection('payments').doc(paymentId);

  // ---- Idempotency gate (single source of truth) ----
  const result = await db.runTransaction(async (tx) => {
    const pSnap = await tx.get(paymentRef);

    const existing = pSnap.exists ? pSnap.data() : null;
    if (existing?.processed === true) {
      return { alreadyProcessed: true };
    }

    tx.set(
      paymentRef,
      {
        provider,
        context,
        referenceId,
        payerId: payerId || existing?.payerId || null,
        amount: amount ?? existing?.amount ?? null,
        currency: currency ?? existing?.currency ?? null,
        status: 'succeeded',
        processed: false,
        succeededAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: existing?.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { alreadyProcessed: false };
  });

  if (result.alreadyProcessed) return { ok: true, alreadyProcessed: true };

  // ---- Apply per context ----
  if (context === 'mediaMarket') {
    const itemRef = db.collection('media_items').doc(referenceId);
    const paymentRef = db.collection('payments').doc(paymentId);
  
    const purchaseId = `${provider}_${paymentId}`;
    const purchaseRef = db.collection('purchases').doc(purchaseId);
  
    const now = admin.firestore.Timestamp.now();
    const downloadDeadline = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 5 * 60 * 1000 // 5 minutes for testing
    );
  
    // Transaction (fee + purchase + paidCount)
    await db.runTransaction(async (tx) => {
      // 1) Ensure item exists
      const itemSnap = await tx.get(itemRef);
      if (!itemSnap.exists) {
         // We don't throw to avoid breaking the webhook, just keep the payment recorded
        return;
      }
      const item = itemSnap.data();
  
      // 2) fetch sellerId
      const sellerId = item.userId;
      if (!sellerId) {
        throw new Error('mediaMarket: missing sellerId (item.userId)');
      }
  
      // 3) fee tier based on seller paidCount
      const userRef = db.collection('users').doc(sellerId);
      const uSnap = await tx.get(userRef);
      const paidCount = Number(uSnap.data()?.freelancerStats?.paidCount ?? 0);
  
      const rate = computeFeeRate(paidCount);
  
      const gross = toNumber(amount) ?? toNumber(item.price);
      if (gross == null || gross <= 0) {
        throw new Error('mediaMarket: invalid gross amount');
      }
  
      const { platformFee, net: sellerNet } = computeFees(gross, rate);
  
      // 4) idempotent purchase creation (merge)
      tx.set(
        purchaseRef,
        {
          itemId: referenceId,
          buyerId: payerId || null,
  
          sellerId,
          provider,
          paymentRef: paymentId,
  
          amount: gross,
          currency: currency || item.currency || 'EUR',
  
          platformFeeRate: rate,
          platformFee,
          sellerNet,
  
          status: 'paid',
          purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
          downloadDeadline,
        },
        { merge: true }
      );
  
      // 5) increment seller paidCount (first time => 50%)
      tx.set(
        userRef,
         {
                  freelancerStats: {
                    paidCount: paidCount + 1,
                    firstPaidAt: paidCount === 0 ? admin.firestore.FieldValue.serverTimestamp() : (uSnap?.freelancerStats?.firstPaidAt ?? null),
                  }, },
        { merge: true }
      );
  
      // 6) optional: link payment doc to purchaseId (tracking)
      tx.set(
        paymentRef,
        { purchaseId, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
    });

    await paymentRef.update({
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),    });

  
    return { ok: true, applied: 'mediaMarket', purchaseId };
  }


if (context === 'jobContract') {
  const contractRef = db.collection('contracts').doc(referenceId);
  const paymentRefDoc = db.collection('payments').doc(paymentId);

  await db.runTransaction(async (tx) => {
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) return;

    const c = cSnap.data();

    // ✅ idempotent: if not paymentPending, do nothing
    if (c.status !== 'paymentPending') return;

    const freelancerId = c.freelancerId;
    const clientId = c.clientId;

    if (!freelancerId || !clientId) {
      throw new Error('jobContract: missing freelancerId/clientId');
    }

    // ✅ gross from amount (if from webhook) or from contract
    const gross =
        toNumber(amount) ?? toNumber(c.grossAmount);

    if (gross == null || gross <= 0) {
      throw new Error('jobContract: invalid gross amount');
    }

    // fee tier based on freelancer paid count
    const userRef = db.collection('users').doc(freelancerId);
    const uSnap = await tx.get(userRef);
    const u = uSnap.exists ? uSnap.data() : {};

    const paidCount = Number(u?.freelancerStats?.paidCount ?? 0);
    const rate = computeFeeRate(paidCount);

    const { platformFee, net } = computeFees(gross, rate);

    // conversation id maybe already exists
    const convId =
        (typeof c.conversationId === String && c.conversationId.length > 0)
            ? c.conversationId
            : db.collection('conversations').doc().id;

    // ✅ Update contract
    tx.update(contractRef, {
      status: 'funded',
      fundedAt: admin.firestore.FieldValue.serverTimestamp(),
      paymentRef: paymentId,

      grossAmount: gross,// optional: lock gross if desired
      platformFeeRate: rate,
      platformFee,
      freelancerNet: net,

      conversationId: convId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ✅ Create conversation if missing
    if (!c.conversationId) {
      const convRef = db.collection('conversations').doc(convId);
      tx.set(convRef, {
        contractId: referenceId,
        participants: [clientId, freelancerId],
        status: 'open',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // ✅ Increment counter once (since we only come from paymentPending)
    const prevFirstPaidAt = u?.freelancerStats?.firstPaidAt ?? null;
    tx.set(
      userRef,
      {
        freelancerStats: {
          paidCount: paidCount + 1,
          firstPaidAt:
              paidCount == 0 ? admin.firestore.FieldValue.serverTimestamp() : prevFirstPaidAt,
        },
      },
      { merge: true }
    );

    // ✅ (Optional) Link payment to contract for tracking
    tx.set(
      paymentRefDoc,
      { contractId: referenceId, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
  });

  return { ok: true, applied: 'jobContract' };
}


  // hireMe later (chatUnlocked + confirmAgreement + refund rules)
  return { ok: true, applied: 'no-op-unsupported-context-yet' };
}

module.exports = { applyPaymentSucceeded };
