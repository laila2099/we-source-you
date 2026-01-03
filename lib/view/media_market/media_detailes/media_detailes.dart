// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/model/media_item.dart';
// import 'package:we_source_you/view/pay/pay.dart';
// import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';

// class MediaDetailPage extends StatefulWidget {
//   final MediaItem item;
//   const MediaDetailPage({Key? key, required this.item}) : super(key: key);

//   @override
//   State<MediaDetailPage> createState() => _MediaDetailPageState();
// }

// class _MediaDetailPageState extends State<MediaDetailPage> {
//   double userRating = 0;
//   double averageRating = 0;
//   int totalRatings = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadRatings();
//   }

//   Future<void> _loadRatings() async {
//     // Guard against missing ID which can produce invalid JS interop objects on web
//     final id = widget.item.id;
//     if (id == null || id.isEmpty) return;

//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('media_items')
//           .doc(id)
//           .collection('ratings')
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         double sum = 0;
//         double myRating = 0;
//         for (var doc in snapshot.docs) {
//           final data = doc.data();
//           final r = (data['rating'] ?? 0).toDouble();
//           sum += r;
//           if (doc.id == FirebaseAuth.instance.currentUser?.uid) {
//             myRating = r;
//           }
//         }
//         if (!mounted) return;
//         setState(() {
//           averageRating = sum / snapshot.docs.length;
//           totalRatings = snapshot.docs.length;
//           userRating = myRating;
//         });
//       }
//     } catch (e, st) {
//       // Log and avoid crashing the app on web JS interop errors
//       debugPrint('Failed to load ratings: $e\n$st');
//     }
//   }

//   Future<void> _rate(double rating) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final id = widget.item.id;
//     if (id == null || id.isEmpty) return;

//     setState(() {
//       userRating = rating; // تحديث فوري للنجوم
//     });

//     final ratingsRef = FirebaseFirestore.instance
//         .collection('media_items')
//         .doc(id)
//         .collection('ratings');

//     await ratingsRef.doc(user.uid).set({'rating': rating});

//     final snapshot = await ratingsRef.get();

//     double sum = 0;
//     for (var doc in snapshot.docs) {
//       sum += (doc['rating'] ?? 0).toDouble();
//     }

//     final avg = snapshot.docs.isEmpty ? 0 : sum / snapshot.docs.length;

//     // 👇 تحديث الـ media_items
//     await FirebaseFirestore.instance.collection('media_items').doc(id).update({
//       'rating': avg,
//       'ratingCount': snapshot.docs.length,
//     });

//     await _loadRatings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.item.title)),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Image
//             if (widget.item.imageUrl != null &&
//                 widget.item.imageUrl!.isNotEmpty)
//               Image.network(
//                 widget.item.imageUrl!,
//                 width: double.infinity,
//                 height: 250,
//                 fit: BoxFit.cover,
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 height: 250,
//                 color: Colors.grey[200],
//                 child: const Center(child: Text("No Media Preview")),
//               ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.item.title,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "By ${widget.item.author}",
//                     style: const TextStyle(color: Colors.blue, fontSize: 16),
//                   ),
//                   const SizedBox(height: 12),
//                   Text("Price: \$${widget.item.price.toStringAsFixed(2)}"),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Average Rating: ${averageRating.toStringAsFixed(1)} ⭐ ($totalRatings ratings)",
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: List.generate(5, (index) {
//                       final starIndex = index + 1;
//                       return IconButton(
//                         icon: Icon(
//                           Icons.star,
//                           color: starIndex <= userRating
//                               ? Colors.amber
//                               : Colors.grey[300],
//                         ),
//                         onPressed: () => _rate(starIndex.toDouble()),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Description:",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(widget.item.description),
//                 ],
//               ),
//             ),
//             WebHoverButton(text: "Buy", onPressed: _buyProject),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _buyProject() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     try {
//       // البيانات اللي بدنا نخزنها
//       final data = {
//         'ownerId': user.uid,
//         'mediaId': widget.item.id,
//         'mediaTitle': widget.item.title,
//         'budget': widget.item.price,
//         'status': 'pendingPayment',
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       // استخدام add() لإنشاء مستند جديد تلقائياً مع ID
//       final docRef = await FirebaseFirestore.instance
//           .collection('projects')
//           .add(data);

//       // الانتقال لصفحة إدارة المشروع مع تمرير ID
//       Get.to(() => ProjectManagementPage(), arguments: docRef.id);
//     } catch (e) {
//       // التعامل مع الأخطاء على الويب
//       debugPrint('Failed to create project: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء إنشاء المشروع، حاول مرة أخرى',
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/media_item.dart';
import 'package:we_source_you/view/pay/pay.dart';
import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart'; // your responsive helper

class MediaDetailPage extends StatefulWidget {
  final MediaItem item;
  const MediaDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  double userRating = 0;
  double averageRating = 0;
  int totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final id = widget.item.id;
    if (id == null || id.isEmpty) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('media_items')
          .doc(id)
          .collection('ratings')
          .get();

      if (snapshot.docs.isNotEmpty) {
        double sum = 0;
        double myRating = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final r = (data['rating'] ?? 0).toDouble();
          sum += r;
          if (doc.id == FirebaseAuth.instance.currentUser?.uid) {
            myRating = r;
          }
        }
        if (!mounted) return;
        setState(() {
          averageRating = sum / snapshot.docs.length;
          totalRatings = snapshot.docs.length;
          userRating = myRating;
        });
      }
    } catch (e, st) {
      debugPrint('Failed to load ratings: $e\n$st');
    }
  }

  Future<void> _rate(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = widget.item.id;
    if (id == null || id.isEmpty) return;

    setState(() {
      userRating = rating;
    });

    final ratingsRef = FirebaseFirestore.instance
        .collection('media_items')
        .doc(id)
        .collection('ratings');

    await ratingsRef.doc(user.uid).set({'rating': rating});

    final snapshot = await ratingsRef.get();

    double sum = 0;
    for (var doc in snapshot.docs) {
      sum += (doc['rating'] ?? 0).toDouble();
    }

    final avg = snapshot.docs.isEmpty ? 0 : sum / snapshot.docs.length;

    await FirebaseFirestore.instance.collection('media_items').doc(id).update({
      'rating': avg,
      'ratingCount': snapshot.docs.length,
    });

    await _loadRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF89CFF0),
              Color(0xFF0D47A1),
            ], // lightBlue → darkBlue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
          desktop: _buildDesktop(context),
        ),
      ),
    );
  }

  /// ---------------- MOBILE ----------------
  Widget _buildMobile(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(16),
        child: _buildMediaContent(),
      ),
    );
  }

  /// ---------------- TABLET ----------------
  Widget _buildTablet(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(32),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(child: _buildMediaContent()),
            // You can add a preview panel or related media here
            // Expanded(child: _buildRelatedMedia()),
          ],
        ),
      ),
    );
  }

  /// ---------------- DESKTOP ----------------
  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.all(40),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(child: _buildMediaContent()),
            // Optional side panel for desktop
            // Expanded(child: _buildRelatedMedia()),
          ],
        ),
      ),
    );
  }

  /// ---------------- CARD DECORATION ----------------
  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.grey[900] : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// ---------------- MEDIA CONTENT ----------------
  Widget _buildMediaContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Image
          if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
            Image.network(
              widget.item.imageUrl!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: const Center(child: Text("No Media Preview")),
            ),
          const SizedBox(height: 16),
          Text(
            widget.item.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "By ${widget.item.author}",
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text("Price: \$${widget.item.price.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          Text(
            "Average Rating: ${averageRating.toStringAsFixed(1)} ⭐ ($totalRatings ratings)",
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: starIndex <= userRating
                      ? Colors.amber
                      : Colors.grey[300],
                ),
                onPressed: () => _rate(starIndex.toDouble()),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            "Description:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(widget.item.description),
          const SizedBox(height: 16),
          WebHoverButton(text: "Buy", onPressed: _buyProject),
        ],
      ),
    );
  }

  Future<void> _buyProject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final data = {
        'ownerId': user.uid,
        'mediaId': widget.item.id,
        'mediaTitle': widget.item.title,
        'budget': widget.item.price,
        'status': 'pendingPayment',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('projects')
          .add(data);

      Get.to(() => ProjectManagementPage(), arguments: docRef.id);
    } catch (e) {
      debugPrint('Failed to create project: $e');
      Get.snackbar(
        'Error',
        'Failed to create project. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
