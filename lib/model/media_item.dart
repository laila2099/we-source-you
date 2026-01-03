class MediaItem {
  final String? id;
  final String title;
  final String author;
  final double price;
  final int views;
  final int ratingCount;
  final String? imageUrl;
  final bool isVerified;
  final String category;
  final String license;
  final String mediaType;
  final String description;

  MediaItem({
    this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.description,
    this.views = 0,
    this.ratingCount = 0,
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
      description: data["description"]?.toString() ?? "",
      author: data["author"]?.toString() ?? "Unknown",
      // تحويل آمن للأرقام لضمان عدم حدوث TypeError
      price: (data["price"] ?? 0.0).toDouble(),
      views: (data["views"] ?? 0).toInt(),
      ratingCount: (data['ratingCount'] ?? 0).toInt(),
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
      "ratingCount": ratingCount,
      "imageUrl": imageUrl,
      "isVerified": isVerified,
      "category": category,
      "license": license,
      "mediaType": mediaType,
      "description": description,
    };
  }
}
