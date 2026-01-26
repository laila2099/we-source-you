import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/category_item.dart';
import 'package:we_source_you/model/media_item.dart';
import 'package:we_source_you/routes/app_routes.dart';

import '../../../core/payments/payment_context.dart';
import '../../../core/payments/payment_provider.dart';
import '../../../core/services/payments/payment_service.dart';

class MediaController extends GetxController {
  final featuredMedia = <MediaItem>[].obs;
  final discoverMedia = <MediaItem>[].obs;
  final categories = <CategoryItem>[].obs;

  final filterCategories = <String>{}.obs;
  final filterLicense = <String>{}.obs;
  final filterMediaType = <String>{}.obs;
  final sortBy = "Newest First".obs;
  final searchQuery = "".obs;

  late final TextEditingController minPriceController;
  late final TextEditingController maxPriceController;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers safely
    minPriceController = TextEditingController(text: "0");
    maxPriceController = TextEditingController(text: "10000");

    _loadCategories();
  }

  @override
  void onReady() {
    super.onReady();

    loadFilteredMedia();

    debounce(
      searchQuery,
      (_) => loadFilteredMedia(),
      time: const Duration(milliseconds: 600),
    );
    everAll([filterCategories, filterLicense, filterMediaType, sortBy], (_) {
      loadFilteredMedia();
    });
  }

  void _loadCategories() {
    categories.assignAll([
      CategoryItem("photo", Icons.camera_alt, Colors.red.shade100, Colors.red),
      CategoryItem("video", Icons.movie, Colors.pink.shade100, Colors.pink),
      CategoryItem("audio", Icons.mic, Colors.purple.shade100, Colors.purple),
      CategoryItem(
        "document",
        Icons.description,
        Colors.blue.shade100,
        Colors.blue,
      ),
      CategoryItem(
        "other",
        Icons.grid_view,
        Colors.orange.shade100,
        Colors.orange,
      ),
    ]);
  }

  // Options
  final List<String> mediaTypeOptions = ["photo", "video", "audio", "document"];
  final List<String> licenseOptions = ["Standard", "Exclusive"];
  final List<String> categoryOptions = [
    "photo",
    "video",
    "audio",
    "document",
    "other",
  ];
  final List<String> sortOptions = [
    "Newest First",
    "Oldest First",
    "Price: High to Low",
    "Most Popular",
  ];

  void toggleFilter(RxSet<String> set, String value) =>
      set.contains(value) ? set.remove(value) : set.add(value);

  Future<void> loadFilteredMedia() async {
    try {
      Query query = FirebaseFirestore.instance.collection("media_items");

      final minPrice = double.tryParse(minPriceController.text) ?? 0;
      final maxPrice = double.tryParse(maxPriceController.text) ?? 100000;
      query = query
          .where("price", isGreaterThanOrEqualTo: minPrice)
          .where("price", isLessThanOrEqualTo: maxPrice);

      if (filterCategories.isNotEmpty)
        query = query.where("category", whereIn: filterCategories.toList());
      if (filterMediaType.isNotEmpty)
        query = query.where("mediaType", whereIn: filterMediaType.toList());
      if (filterLicense.isNotEmpty)
        query = query.where("license", whereIn: filterLicense.toList());

      // Sorting (basic, add more logic if needed)
      query = query.orderBy("price");

      final snapshot = await query.get();
      final items = snapshot.docs
          .map(
            (doc) =>
                MediaItem.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      discoverMedia.assignAll(items);
      featuredMedia.assignAll(
        items.where((item) => item.ratingCount >= 4.0).toList(),
      );
    } catch (e) {
      debugPrint("🔥 Firestore Error: $e");
    }
  }

  void clearFilters({bool reload = true}) {
    filterCategories.clear();
    filterLicense.clear();
    filterMediaType.clear();
    sortBy.value = "Newest First";
    searchQuery.value = "";
    minPriceController.text = "0";
    maxPriceController.text = "10000";

    if (reload) {
      loadFilteredMedia();
    }
  }

  Future<void> loadMediaByCategory(String category) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection("media_items")
          .where("category", isEqualTo: category);
      final snapshot = await query.get();

      final items = snapshot.docs
          .map(
            (doc) =>
                MediaItem.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      discoverMedia.assignAll(items);
    } catch (e) {
      debugPrint("🔥 Category Query Error: $e");
    }
  }

  void setSort(String value) => sortBy.value = value;
  void goBack() => Get.back();
  void updateRating(String mediaId, double rating, int count) {
    void updateList(List<MediaItem> list) {
      final index = list.indexWhere((item) => item.id == mediaId);
      if (index != -1) {
        final old = list[index];
        list[index] = MediaItem(
          id: old.id,
          title: old.title,
          author: old.author,
          price: old.price,
          description: old.description,
          views: old.views,
          imageUrl: old.imageUrl,
          isVerified: old.isVerified,
          category: old.category,
          license: old.license,
          mediaType: old.mediaType,
          rating: rating,
          ratingCount: count,
        );
      }
    }

    updateList(discoverMedia);
    updateList(featuredMedia);
  }

  ///  ---------------------- Payment ----------------------
  Future<void> buy(String itemId, PaymentProvider provider) async {
    final baseUrl = Uri.base.origin;
    final successUrl = '$baseUrl/#${AppRoutes.myLibrary}';
    final cancelUrl = '$baseUrl/#${AppRoutes.media}';

    print(itemId);

    await PaymentService().startWebCheckout(
      provider: provider,
      context: PaymentContext.mediaMarket,
      referenceId: itemId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
  }

  Future<void> downloadPurchase(String purchaseId) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

    final res = await functions.httpsCallable('getDownloadUrl').call({
      'purchaseId': purchaseId,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) throw Exception('Missing signed url');
    if (Get.isDialogOpen!) Get.back();

    if (url == null || url.isEmpty) throw Exception('Missing signed url');
    html.window.open(url, '_blank');
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.currentRoute != AppRoutes.myLibrary) {
        Get.toNamed(AppRoutes.myLibrary);
      }
    });
  }

  @override
  void onClose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }
}
