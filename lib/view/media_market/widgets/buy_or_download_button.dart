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
    print(itemId);
    print(uid);
    if (uid == null) return const SizedBox.shrink();

    final stream = FirebaseFirestore.instance
        .collection('purchases')
        .where('buyerId', isEqualTo: uid)
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'paid')
        .orderBy('downloadDeadline', descending: false)
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
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        print(docs);

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
        final purchaseDoc = docs.last;
        final data = purchaseDoc.data();

        final deadlineTs = data['downloadDeadline'] as Timestamp?;
        final deadline = deadlineTs?.toDate();
        final expired = (deadline == null)
            ? true
            : DateTime.now().isAfter(deadline);

        print(deadline);
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
