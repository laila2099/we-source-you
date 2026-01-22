import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MediaRatingWidget extends StatefulWidget {
  final String mediaId;

  /// Callback اختياري لو حابة تحدثي List أو Controller خارجي
  final Function(double avg, int count)? onRatingUpdated;

  const MediaRatingWidget({
    Key? key,
    required this.mediaId,
    this.onRatingUpdated,
  }) : super(key: key);

  @override
  State<MediaRatingWidget> createState() => _MediaRatingWidgetState();
}

class _MediaRatingWidgetState extends State<MediaRatingWidget> {
  double userRating = 0;
  double averageRating = 0;
  int totalRatings = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      /// 1️⃣ جلب المتوسط المخزن
      final mediaDoc = await FirebaseFirestore.instance
          .collection('media_items')
          .doc(widget.mediaId)
          .get();

      if (mediaDoc.exists) {
        final data = mediaDoc.data();
        averageRating = (data?['rating'] ?? 0).toDouble();
        totalRatings = (data?['ratingCount'] ?? 0).toInt();
      }

      /// 2️⃣ جلب تقييم المستخدم الحالي
      if (user != null) {
        final userRatingDoc = await FirebaseFirestore.instance
            .collection('media_items')
            .doc(widget.mediaId)
            .collection('ratings')
            .doc(user.uid)
            .get();

        if (userRatingDoc.exists) {
          userRating = (userRatingDoc.data()?['rating'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Rating load error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _rate(double rating) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar(
        "Login Required",
        "Please login to rate",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => userRating = rating);

    try {
      final ratingsRef = FirebaseFirestore.instance
          .collection('media_items')
          .doc(widget.mediaId)
          .collection('ratings');

      /// حفظ تقييم المستخدم
      await ratingsRef.doc(user.uid).set({
        'rating': rating,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      /// إعادة الحساب
      final snapshot = await ratingsRef.get();

      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc.data()['rating'] ?? 0).toDouble();
      }

      final count = snapshot.docs.length;
      final avg = count > 0 ? (sum / count).toDouble() : 0.0;

      /// تحديث الدوكمنت الأساسي
      await FirebaseFirestore.instance
          .collection('media_items')
          .doc(widget.mediaId)
          .update({'rating': avg, 'ratingCount': count});

      if (mounted) {
        setState(() {
          averageRating = avg;
          totalRatings = count;
        });
      }

      widget.onRatingUpdated?.call(avg, count);
    } catch (e) {
      debugPrint('Rating error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rating & Reviews",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStars(),
                Text(
                  "$totalRatings ratings",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return InkWell(
          onTap: () => _rate(starValue.toDouble()),
          child: Icon(
            Icons.star,
            size: 28,
            color: starValue <= userRating ? Colors.amber : Colors.grey[300],
          ),
        );
      }),
    );
  }
}
