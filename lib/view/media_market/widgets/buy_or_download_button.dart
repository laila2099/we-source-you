import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_buttom/custom_buttom.dart';
import '../../../widgets/payment_method_dialog.dart';
import '../media_market_controller/media_market_controller.dart';

class BuyOrDownloadButton extends StatelessWidget {
  final String itemId;
  const BuyOrDownloadButton({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print(uid);
    print(itemId);
    if (uid == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('purchases')
        .where('buyerId', isEqualTo: uid)
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'paid')
        .limit(1)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // خليها نفس حجم الزر بدل دائرة لحالها
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        print(snapshot.data);

        final docs = snapshot.data?.docs ?? [];

        // ✅ ما اشترى: Buy
        if (docs.isEmpty) {
          return WebHoverButton(
            text: 'Buy now',
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () async {
              final provider = await showPaymentMethodDialog(context);
              if (provider == null) return;
              controller.buy(itemId, provider);
            },
            width: double.infinity,
          );
        }

        // ✅ اشترى: Download / Expired
        final purchaseDoc = docs.first;
        final data = purchaseDoc.data();

        final deadlineTs = data['downloadDeadline'] as Timestamp?;
        final deadline = deadlineTs?.toDate();
        final expired = (deadline == null)
            ? true
            : DateTime.now().isAfter(deadline);

        print(data);
        print(purchaseDoc.id);
        if (expired) {
          return WebHoverButton(
            text: 'Buy now',
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () async {
              final provider = await showPaymentMethodDialog(context);
              if (provider == null) return;
              controller.buy(itemId, provider);
            },
            width: double.infinity,
          );
        }

        return WebHoverButton(
          text: 'Download',
          icon: const Icon(Icons.download, color: Colors.white, size: 18),
          onPressed: () => controller.downloadPurchase(purchaseDoc.id),
          width: double.infinity,
        );
      },
    );
  }
}
