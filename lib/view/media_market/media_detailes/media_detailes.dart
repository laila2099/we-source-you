import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/model/media_item.dart';
import 'package:we_source_you/view/jobs/job_proposals/job_proposals_view.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';
import 'package:we_source_you/widgets/rating.dart';

import '../widgets/buy_or_download_button.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaItem item;
  const MediaDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  double userRating = 0; // تقييم المستخدم الحالي
  double averageRating = 0; // متوسط التقييم العام
  int totalRatings = 0; // عدد المقيمين
  bool _isLoading = true; // حالة التحميل

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// تحميل التقييمات عند فتح الصفحة
  Future<void> _loadInitialData() async {
    final mediaId = widget.item.id;
    final user = FirebaseAuth.instance.currentUser;

    if (mediaId == null || mediaId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. جلب بيانات المنتج الأساسية للحصول على المتوسط المحفوظ مسبقاً (أسرع من حساب الكل)
      final docSnapshot = await FirebaseFirestore.instance
          .collection('media_items')
          .doc(mediaId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        // نستخدم القيم الموجودة أو 0 في حال عدم وجودها
        averageRating = (data?['rating'] ?? 0).toDouble();
        totalRatings = (data?['ratingCount'] ?? 0).toInt();
      }

      // 2. التحقق مما إذا كان المستخدم الحالي قد قيم هذا العنصر سابقاً
      if (user != null) {
        final ratingDoc = await FirebaseFirestore.instance
            .collection('media_items')
            .doc(mediaId)
            .collection('ratings')
            .doc(user.uid)
            .get();

        if (ratingDoc.exists) {
          userRating = (ratingDoc.data()?['rating'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// دالة إضافة التقييم
  Future<void> _rate(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    final mediaId = widget.item.id;

    // 1. التحقق من تسجيل الدخول
    if (user == null) {
      Get.snackbar(
        "تنبيه",
        "يجب عليك تسجيل الدخول لتقييم المنتج",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (mediaId == null) return;

    // 2. التحديث التفاؤلي (تحديث الواجهة فوراً قبل انتظار السيرفر)
    setState(() {
      userRating = rating;
    });

    try {
      final ratingsRef = FirebaseFirestore.instance
          .collection('media_items')
          .doc(mediaId)
          .collection('ratings');

      // حفظ تقييم المستخدم في Sub-Collection
      // نستخدم merge: true لضمان عدم حذف حقول أخرى مثل timestamp لو أضفتها مستقبلاً
      await ratingsRef.doc(user.uid).set({
        'rating': rating,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. إعادة حساب المتوسط (Aggregation)
      // ملاحظة: في التطبيقات الكبيرة جداً يفضل عمل هذا الجزء عبر Cloud Functions
      // ولكن للكود الحالي، سنقوم بحسابه محلياً وتحديثه.
      final snapshot = await ratingsRef.get();

      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc.data()['rating'] ?? 0).toDouble();
      }

      final count = snapshot.docs.length;
      final avg = count > 0 ? sum / count : 0.0;

      // تحديث الوثيقة الرئيسية بالمتوسط والعدد الجديد
      await FirebaseFirestore.instance
          .collection('media_items')
          .doc(mediaId)
          .update({'rating': avg, 'ratingCount': count});

      // تحديث الواجهة بالقيم الجديدة المحسوبة من السيرفر
      if (mounted) {
        setState(() {
          averageRating = avg;
          totalRatings = count;
        });

        Get.find<MediaController>().updateRating(mediaId, avg, count);
      }
    } catch (e) {
      debugPrint('Failed to rate: $e');
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء حفظ التقييم",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white), // زر رجوع واضح
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF89CFF0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ResponsiveLayout(
                mobile: _buildLayout(context, isMobile: true),
                tablet: _buildLayout(context, isMobile: false),
                desktop: _buildLayout(context, isMobile: false),
              ),
      ),
    );
  }

  /// دالة موحدة لبناء التصميم لتجنب التكرار
  Widget _buildLayout(BuildContext context, {required bool isMobile}) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? 500 : 1000),
        margin: EdgeInsets.all(isMobile ? 16 : 40),
        decoration: _cardDecoration(context),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: isMobile
            ? _buildMediaContent()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: _buildMediaContent())],
              ),
      ),
    );
  }

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

  Widget _buildMediaContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                (widget.item.imageUrl != null &&
                    widget.item.imageUrl!.isNotEmpty)
                ? Image.network(
                    widget.item.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(child: Text("No Media Preview")),
                  ),
          ),
          const SizedBox(height: 20),

          // العنوان
          Text(
            widget.item.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // المؤلف
          Text(
            "By ${widget.item.author}",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // السعر
          Text(
            "\$${widget.item.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 8),

          Row(
            children: [
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaRatingWidget(
                    mediaId: widget.item.id!,
                    onRatingUpdated: (avg, count) {
                      Get.find<MediaController>().updateRating(
                        widget.item.id!,
                        avg,
                        count,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 30),

          // الوصف
          const Text(
            "Description:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(widget.item.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 30),

          // زر الشراء
          Center(
            child: SizedBox(
              width: 200,
              child: BuyOrDownloadButton(itemId: widget.item.id!),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buyProject() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Login Required", "Please login to purchase items.");
      return;
    }

    if (widget.item.id == null) {
      Get.snackbar("Error", "Invalid media item");
      return;
    }

    // Initialize PaymentController if not already initialized
    /*    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    final paymentController = Get.find<PaymentController>();*/

    // Show payment summary sheet
    Get.bottomSheet(
      PaymentSummarySheet(
        title: widget.item.title,
        subtitle: widget.item.description,
        amount: widget.item.price,
        proposalId: '',
        jobId: '',
        teamId: '',
      ),
      isScrollControlled: true,
    );
  }
}
