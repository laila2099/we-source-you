// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/model/category_item.dart';
// import 'package:we_source_you/model/media_item.dart';

// class MediaController extends GetxController {
//   // ===================== STATE =====================
//   final featuredMedia = <MediaItem>[].obs;
//   final discoverMedia = <MediaItem>[].obs;
//   final categories = <CategoryItem>[].obs;

//   // Filters
//   final filterCategories = <String>{}.obs;
//   final filterLicense = <String>{}.obs;
//   final filterMediaType = <String>{}.obs;
//   final sortBy = "Newest First".obs;
//   final searchQuery = "".obs;

//   final minPriceController = TextEditingController(text: "0");
//   final maxPriceController = TextEditingController(text: "10000");

//   // ===================== INIT =====================
//   @override
//   void onInit() {
//     super.onInit();
//     _loadCategories();
//     loadFilteredMedia();

//     debounce(
//       searchQuery,
//       (_) => loadFilteredMedia(),
//       time: const Duration(milliseconds: 500),
//     );

//     everAll([
//       filterCategories,
//       filterLicense,
//       filterMediaType,
//       sortBy,
//     ], (_) => loadFilteredMedia());
//   }

//   // ===================== DATA =====================
//   void _loadCategories() {
//     categories.assignAll([
//       CategoryItem("audio", Icons.mic, Colors.purple.shade100, Colors.purple),
//       CategoryItem(
//         "document",
//         Icons.description,
//         Colors.blue.shade100,
//         Colors.blue,
//       ),
//       CategoryItem(
//         "footage",
//         Icons.videocam,
//         Colors.green.shade100,
//         Colors.green,
//       ),
//       CategoryItem(
//         "other",
//         Icons.grid_view,
//         Colors.orange.shade100,
//         Colors.orange,
//       ),
//       CategoryItem("photo", Icons.camera_alt, Colors.red.shade100, Colors.red),
//       CategoryItem("video", Icons.movie, Colors.pink.shade100, Colors.pink),
//     ]);
//   }

// void toggleFilter(RxSet<String> set, String value) {
//   set.contains(value) ? set.remove(value) : set.add(value);
// }

//   void clearFilters() {
//     filterCategories.clear();
//     filterLicense.clear();
//     filterMediaType.clear();
//     sortBy.value = "Newest First";
//     searchQuery.value = "";
//     minPriceController.text = "0";
//     maxPriceController.text = "10000";
//     loadFilteredMedia();
//   }

//   void goBack() => Get.back();
//   void setSort(String value) {
//     sortBy.value = value;
//   }

//   final List<String> mediaTypeOptions = ["Image", "Video", "Audio", "Document"];
//   final List<String> licenseOptions = ["Standard", "Exclusive"];
//   final List<String> categoryOptions = [
//     "Photography",
//     "Video",
//     "Design",
//     "Audio",
//     "Writing",
//     "Templates",
//     "Other",
//   ];
//   final List<String> sortOptions = [
//     "Newest First",
//     "Oldest First",
//     "Price: Low to High",
//     "Price: High to Low",
//     "Most Popular",
//     "Highest Rated",
//   ];
//   // ===================== FIRESTORE QUERY =====================
//   Future<void> loadFilteredMedia() async {
//     try {
//       Query query = FirebaseFirestore.instance
//           .collection("media_items")
//           .orderBy("price"); // 🔑 REQUIRED for range

//       // ---- PRICE RANGE ----
//       final minPrice = double.tryParse(minPriceController.text) ?? 0;
//       final maxPrice = double.tryParse(maxPriceController.text) ?? 100000;

//       query = query
//           .where("price", isGreaterThanOrEqualTo: minPrice)
//           .where("price", isLessThanOrEqualTo: maxPrice);

//       // ---- CATEGORY ----
//       if (filterCategories.isNotEmpty) {
//         query = query.where("category", whereIn: filterCategories.toList());
//       }

//       // ---- MEDIA TYPE ----
//       if (filterMediaType.isNotEmpty) {
//         query = query.where("mediaType", whereIn: filterMediaType.toList());
//       }

//       // ---- LICENSE ----
//       if (filterLicense.isNotEmpty) {
//         query = query.where("license", whereIn: filterLicense.toList());
//       }

//       // ---- SEARCH ----
//       if (searchQuery.value.isNotEmpty) {
//         query = query.where(
//           "keywords",
//           arrayContains: searchQuery.value.toLowerCase(),
//         );
//       }

//       // ---- SORTING ----
//       switch (sortBy.value) {
//         case "Newest First":
//           query = query.orderBy("timestamp", descending: true);
//           break;
//         case "Oldest First":
//           query = query.orderBy("timestamp");
//           break;
//         case "Price: High to Low":
//           query = query.orderBy("price", descending: true);
//           break;
//         case "Most Popular":
//           query = query.orderBy("views", descending: true);
//           break;
//         case "Highest Rated":
//           query = query.orderBy("rating", descending: true);
//           break;
//       }

//       final snapshot = await query.get();

//       final items = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return MediaItem(
//           title: data["title"] ?? "",
//           author: data["author"] ?? "",
//           price: (data["price"] ?? 0).toDouble(),
//           views: data["views"] ?? 0,
//           rating: (data["rating"] ?? 0.0).toDouble(),
//           imageUrl: data["imageUrl"],
//           isVerified: data["isVerified"] ?? false,
//           category: data["category"],
//           mediaType: data["mediaType"],
//         );
//       }).toList();

//       featuredMedia.assignAll(items);
//       discoverMedia.assignAll(items);
//     } catch (e) {
//       debugPrint("🔥 Firestore Query Error: $e");
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/category_item.dart';
import 'package:we_source_you/model/media_item.dart';

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
      CategoryItem("audio", Icons.mic, Colors.purple.shade100, Colors.purple),
      CategoryItem(
        "document",
        Icons.description,
        Colors.blue.shade100,
        Colors.blue,
      ),
      CategoryItem(
        "footage",
        Icons.videocam,
        Colors.green.shade100,
        Colors.green,
      ),
      CategoryItem(
        "other",
        Icons.grid_view,
        Colors.orange.shade100,
        Colors.orange,
      ),
      CategoryItem("photo", Icons.camera_alt, Colors.red.shade100, Colors.red),
      CategoryItem("video", Icons.movie, Colors.pink.shade100, Colors.pink),
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
        items.where((item) => item.rating >= 4.0).toList(),
      );
    } catch (e) {
      debugPrint("🔥 Firestore Error: $e");
    }
  }

  void clearFilters() {
    filterCategories.clear();
    filterLicense.clear();
    filterMediaType.clear();
    sortBy.value = "Newest First";
    searchQuery.value = "";
    minPriceController.text = "0";
    maxPriceController.text = "10000";
    loadFilteredMedia();
  }

  void setSort(String value) => sortBy.value = value;
  void goBack() => Get.back();

  @override
  void onClose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }
}
