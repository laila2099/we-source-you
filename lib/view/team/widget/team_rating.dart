import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TeamRatingWidget extends StatefulWidget {
  final String teamMemberId;
  final Function(double avg, int count)? onRatingUpdated;

  const TeamRatingWidget({
    Key? key,
    required this.teamMemberId,
    this.onRatingUpdated,
  }) : super(key: key);

  @override
  State<TeamRatingWidget> createState() => _TeamRatingWidgetState();
}

class _TeamRatingWidgetState extends State<TeamRatingWidget> {
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
      // 1️⃣ جلب بيانات العضو الأساسية (المتوسط والعدد)
      final memberDoc = await FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamMemberId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data();
        // تأكدي من مسميات الحقول في قاعدة بياناتك (rating و reviews)
        averageRating = (data?['rating'] ?? 0).toDouble();
        totalRatings = (data?['reviews'] ?? 0).toInt();
      }

      // 2️⃣ جلب تقييم المستخدم الحالي للعضو
      if (user != null) {
        final ratingDoc = await FirebaseFirestore.instance
            .collection('team')
            .doc(widget.teamMemberId)
            .collection('ratings')
            .doc(user.uid)
            .get();

        if (ratingDoc.exists) {
          userRating = (ratingDoc.data()?['rating'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error loading team ratings: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _rate(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Login Required", "Please login to rate this member");
      return;
    }

    setState(() => userRating = rating);

    try {
      final ratingsRef = FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamMemberId)
          .collection('ratings');

      // حفظ/تحديث تقييم المستخدم
      await ratingsRef.doc(user.uid).set({
        'rating': rating,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // حساب المتوسط الجديد
      final snapshot = await ratingsRef.get();
      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc.data()['rating'] ?? 0).toDouble();
      }

      final count = snapshot.docs.length;
      final avg = count > 0 ? (sum / count) : 0.0;

      // تحديث الدوكمنت الأساسي للعضو
      await FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamMemberId)
          .update({
            'rating': avg,
            'reviews': count, // حدثنا reviews ليتناسب مع موديل TeamModel
          });

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
    if (isLoading)
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStars(),
                Text(
                  "$totalRatings reviews",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
            size: 24,
            color: starValue <= userRating ? Colors.amber : Colors.grey[300],
          ),
        );
      }),
    );
  }
}
