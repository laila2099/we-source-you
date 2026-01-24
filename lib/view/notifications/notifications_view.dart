// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';

// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({super.key});

//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   final String uid = FirebaseAuth.instance.currentUser!.uid;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermission();
//     _listenFCM();
//   }

//   /// طلب إذن الإشعارات (خصوصاً للويب وiOS)
//   Future<void> _requestPermission() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//       debugPrint('User declined notification permissions');
//     }
//   }

//   /// استماع للإشعارات أثناء تشغيل التطبيق
//   void _listenFCM() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       final data = message.data;
//       final notifId =
//           data['id'] ?? message.messageId ?? DateTime.now().toIso8601String();

//       // إضافة الإشعار للـ Firestore مباشرة (سيظهر في الـ StreamBuilder)
//       _firestore.collection('notifications').add({
//         'userId': uid,
//         'title': data['title'] ?? message.notification?.title ?? 'Notification',
//         'body': data['body'] ?? message.notification?.body ?? '',
//         'type': data['type'] ?? 'default',
//         'createdAt': FieldValue.serverTimestamp(),
//         'read': false,
//         'id': notifId,
//       });
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // ممكن توجيه المستخدم عند الضغط على الإشعار
//       debugPrint('Notification tapped: ${message.notification?.title}');
//     });
//   }

//   IconData _iconForType(String type) {
//     switch (type) {
//       case 'kyc':
//         return Icons.verified_user;
//       case 'payment':
//         return Icons.payment;
//       default:
//         return Icons.notifications;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('notifications')
//             .where('userId', isEqualTo: uid)
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No notifications yet'));
//           }

//           final notifications = snapshot.data!.docs;

//           return ListView.separated(
//             itemCount: notifications.length,
//             separatorBuilder: (_, __) => const Divider(height: 0),
//             itemBuilder: (context, index) {
//               final doc = notifications[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final bool isRead = data['read'] ?? false;

//               return ListTile(
//                 leading: Icon(
//                   _iconForType(data['type'] ?? 'default'),
//                   color: isRead ? Colors.grey : Colors.blue,
//                 ),
//                 title: Text(
//                   data['title'] ?? '',
//                   style: TextStyle(
//                     fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Text(data['body'] ?? ''),
//                 trailing: !isRead
//                     ? const Icon(Icons.circle, size: 10, color: Colors.blue)
//                     : null,
//                 onTap: () async {
//                   if (!isRead) {
//                     await doc.reference.update({'read': true});
//                   }
//                   // هنا ممكن تضيف Navigation لتفاصيل الإشعار إذا عندك صفحة خاصة
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/notification_model.dart';
import 'package:we_source_you/routes/app_routes.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: const Center(child: Text("Please sign in to view notifications")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(user.uid),
            tooltip: "Mark all as read",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!.docs.map((doc) {
            return NotificationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'proposal_received':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'proposal_approved':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'proposal_rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.circle, size: 8, color: Colors.blue),
        onTap: () {
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .update({'isRead': true});
    }

    // Navigate based on notification type
    if (notification.jobId != null) {
      // Navigate to job details or proposals
      if (notification.type == 'proposal_received') {
        // Navigate to job proposals view
        Get.snackbar(
          "Info",
          "Navigate to job proposals",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (notification.type == 'proposal_approved') {
        // Navigate to job details
        Get.toNamed(AppRoutes.applyJob, arguments: notification.jobId);
      }
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    Get.snackbar(
      "Success",
      "All notifications marked as read",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
