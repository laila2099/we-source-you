// class MediaItem {
//   String? id; // nullable, لتسهيل الإنشاء قبل Firestore
//   final String title;
//   final String author;
//   final double price;
//   final int views;
//   final double rating;
//   final String? imageUrl;
//   final bool isVerified;

//   // فلاتر اختيارية مع قيم افتراضية
//   final String category;
//   final String license;
//   final String mediaType;

//   MediaItem({
//     this.id,
//     required this.title,
//     required this.author,
//     required this.price,
//     this.views = 0,
//     this.rating = 0.0,
//     this.imageUrl,
//     this.isVerified = false,
//     this.category = "other",
//     this.license = "standard",
//     this.mediaType = "image",
//   });

//   // Factory لتحويل Map من Firestore إلى MediaItem
//   factory MediaItem.fromMap(Map<String, dynamic> data, String id) {
//     return MediaItem(
//       id: id,
//       title: data["title"] ?? "",
//       author: data["author"] ?? "",
//       price: (data["price"] ?? 0).toDouble(),
//       views: (data["views"] ?? 0),
//       rating: (data["rating"] ?? 0.0).toDouble(),
//       imageUrl: data["imageUrl"],
//       isVerified: data["isVerified"] ?? false,
//       category: data["category"] ?? "other",
//       license: data["license"] ?? "standard",
//       mediaType: data["mediaType"] ?? "image",
//     );
//   }

//   // تحويل MediaItem إلى Map لحفظه في Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       "title": title,
//       "author": author,
//       "price": price,
//       "views": views,
//       "rating": rating,
//       "imageUrl": imageUrl,
//       "isVerified": isVerified,
//       "category": category,
//       "license": license,
//       "mediaType": mediaType,
//     };
//   }
// }
class MediaItem {
  final String? id;
  final String title;
  final String author;
  final double price;
  final int views;
  final double rating;
  final String? imageUrl;
  final bool isVerified;
  final String category;
  final String license;
  final String mediaType;

  MediaItem({
    this.id,
    required this.title,
    required this.author,
    required this.price,
    this.views = 0,
    this.rating = 0.0,
    this.imageUrl,
    this.isVerified = false,
    this.category = "other",
    this.license = "standard",
    this.mediaType = "image",
  });

  factory MediaItem.fromMap(Map<String, dynamic> data, String id) {
    return MediaItem(
      id: id,
      title: data["title"]?.toString() ?? "",
      author: data["author"]?.toString() ?? "Unknown",
      // تحويل آمن للأرقام لضمان عدم حدوث TypeError
      price: (data["price"] ?? 0.0).toDouble(),
      views: (data["views"] ?? 0).toInt(),
      rating: (data["rating"] ?? 0.0).toDouble(),
      imageUrl: data["imageUrl"],
      isVerified: data["isVerified"] ?? false,
      category: data["category"] ?? "other",
      license: data["license"] ?? "standard",
      mediaType: data["mediaType"] ?? "image",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "author": author,
      "price": price,
      "views": views,
      "rating": rating,
      "imageUrl": imageUrl,
      "isVerified": isVerified,
      "category": category,
      "license": license,
      "mediaType": mediaType,
    };
  }
}
