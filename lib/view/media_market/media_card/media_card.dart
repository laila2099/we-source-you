// import 'package:flutter/material.dart';
// import 'package:we_source_you/model/media_item.dart';
// import 'package:we_source_you/view/media_market/media_detailes/media_detailes.dart';

// class MediaCard extends StatelessWidget {
//   final MediaItem item;

//   const MediaCard({Key? key, required this.item}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => MediaDetailPage(item: item)),
//         );
//       },
//       child: Container(
//         width: 280, // Match the wide aspect ratio
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Image Area
//             // 1. Image Area
//             // 1. Image Area
//             Expanded(
//               child: Stack(
//                 children: [
//                   // Show user's uploaded image if exists, else placeholder
//                   SizedBox.expand(
//                     child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                         ? Image.network(
//                             item.imageUrl!,
//                             fit: BoxFit.cover, // تغطي كل مساحة الـ Container
//                             width: double.infinity,
//                             height: double.infinity,
//                             loadingBuilder: (context, child, progress) {
//                               if (progress == null) return child;
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return Center(
//                                 child: Text(
//                                   "Failed to load",
//                                   style: TextStyle(color: Colors.grey[400]),
//                                 ),
//                               );
//                             },
//                           )
//                         : Container(
//                             color: const Color(0xFFF5F5F5),
//                             child: Center(
//                               child: Text(
//                                 "Media Preview",
//                                 style: TextStyle(color: Colors.grey[400]),
//                               ),
//                             ),
//                           ),
//                   ),
//                   // Title Overlay Gradient
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                             Colors.black.withOpacity(0.6),
//                             Colors.transparent,
//                           ],
//                         ),
//                       ),
//                       child: Text(
//                         item.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // 2. Info Area
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             item.author,
//                             style: const TextStyle(
//                               color: Colors.blue,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           if (item.isVerified)
//                             const Icon(
//                               Icons.check,
//                               size: 12,
//                               color: Colors.blue,
//                             ),
//                         ],
//                       ),
//                       Text(
//                         "\$${item.price.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.remove_red_eye_outlined,
//                             size: 14,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             "${item.views} views",
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Icon(Icons.star, size: 14, color: Colors.amber),
//                           const SizedBox(width: 2),
//                           Text(
//                             item.rating.toStringAsFixed(2),
//                             style: const TextStyle(
//                               color: Colors.amber,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:we_source_you/model/media_item.dart';
import 'package:we_source_you/view/media_market/media_detailes/media_detailes.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;

  const MediaCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MediaDetailPage(item: item)),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF5F5F5),
                            child: Center(
                              child: Text(
                                "Media Preview",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item.ratingCount.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
