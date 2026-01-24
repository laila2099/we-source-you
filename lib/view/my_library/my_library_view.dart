import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyLibraryPage extends StatelessWidget {
  const MyLibraryPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> myPurchasesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('purchases')
        .where('buyerId', isEqualTo: uid)
        .where('status', isEqualTo: 'paid')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myPurchasesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final purchases = snap.data?.docs ?? [];
          if (purchases.isEmpty) {
            return const Center(child: Text('No purchases yet.'));
          }

          return ListView.separated(
            itemCount: purchases.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final purchaseDoc = purchases[i];
              final p = purchaseDoc.data();
              final itemId = p['itemId'] as String?;

              if (itemId == null || itemId.isEmpty) {
                return const ListTile(title: Text('Purchase without itemId'));
              }

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('media_items')
                    .doc(itemId)
                    .get(),
                builder: (context, itemSnap) {
                  final item = itemSnap.data?.data();
                  final title = item?['title'] ?? 'Item';
                  final imageUrl = item?['imageUrl'] as String?;

                  final deadline = p['downloadDeadline'] as Timestamp?;
                  final expired =
                      deadline != null &&
                      DateTime.now().isAfter(deadline.toDate());

                  return ListTile(
                    leading: (imageUrl != null && imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(width: 48, height: 48),
                    title: Text(title),
                    subtitle: Text(
                      expired ? 'Download expired' : 'Ready for download',
                    ),
                    trailing: ElevatedButton(
                      onPressed: expired
                          ? null
                          : () async {
                              final functions = FirebaseFunctions.instanceFor(
                                region: 'us-central1',
                              );
                              final res = await functions
                                  .httpsCallable('getDownloadUrl')
                                  .call({'purchaseId': purchaseDoc.id});

                              final data = Map<String, dynamic>.from(
                                res.data as Map,
                              );
                              final url = data['url'] as String?;
                              if (url == null || url.isEmpty) return;

                              html.window.open(url, '_blank');
                            },
                      child: const Text('Download'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
