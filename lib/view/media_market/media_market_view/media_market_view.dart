// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_source_you/model/media_item.dart';
// import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';
// import 'package:we_source_you/view/media_market/widgets/main_content.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// // ------------------------ MediaView.dart ------------------------

// class MediaView extends GetView<MediaController> {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MediaController>();
//     final theme = Theme.of(context);
//     final authController = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final user = FirebaseAuth.instance.currentUser;
//           if (user == null) {
//             Get.snackbar(
//               "Error",
//               "You must sign in before uploading.",
//               snackPosition: SnackPosition.BOTTOM,
//             );
//             return;
//           }

//           String selectedType = "photo"; // default
//           TextEditingController titleCtrl = TextEditingController();
//           TextEditingController priceCtrl = TextEditingController();
//           XFile? pickedMedia;
//           PlatformFile? pickedFile;
//           Uint8List? fileBytes;

//           await Get.dialog(
//             StatefulBuilder(
//               builder: (context, setState) {
//                 return AlertDialog(
//                   title: const Text("Upload Media"),
//                   content: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         DropdownButtonFormField<String>(
//                           value: selectedType,
//                           items:
//                               ["photo", "video", "audio", "document", "other"]
//                                   .map(
//                                     (e) => DropdownMenuItem(
//                                       value: e,
//                                       child: Text(e.capitalize!),
//                                     ),
//                                   )
//                                   .toList(),
//                           onChanged: (val) {
//                             if (val != null) {
//                               setState(() {
//                                 selectedType = val;
//                                 pickedMedia = null;
//                                 pickedFile = null;
//                                 fileBytes = null;
//                               });
//                             }
//                           },
//                           decoration: const InputDecoration(
//                             labelText: "Media Type",
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextField(
//                           controller: titleCtrl,
//                           decoration: const InputDecoration(labelText: "Title"),
//                         ),
//                         const SizedBox(height: 12),
//                         TextField(
//                           controller: priceCtrl,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           decoration: const InputDecoration(labelText: "Price"),
//                         ),
//                         const SizedBox(height: 12),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.attach_file),
//                           label: const Text("Pick File"),
//                           onPressed: () async {
//                             if (selectedType == "photo" ||
//                                 selectedType == "video") {
//                               final picker = ImagePicker();
//                               final file = selectedType == "photo"
//                                   ? await picker.pickImage(
//                                       source: ImageSource.gallery,
//                                     )
//                                   : await picker.pickVideo(
//                                       source: ImageSource.gallery,
//                                     );
//                               if (file != null) {
//                                 setState(() => pickedMedia = file);
//                                 fileBytes = await file.readAsBytes();
//                                 Get.snackbar("File Selected", file.name);
//                               }
//                             } else {
//                               final result = await FilePicker.platform
//                                   .pickFiles(
//                                     allowMultiple: false,
//                                     withData: true,
//                                   );
//                               if (result != null && result.files.isNotEmpty) {
//                                 setState(() => pickedFile = result.files.first);
//                                 fileBytes = pickedFile!.bytes;
//                                 Get.snackbar("File Selected", pickedFile!.name);
//                               }
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         if (fileBytes != null)
//                           Container(
//                             width: double.infinity,
//                             height: selectedType == "photo" ? 150 : 100,
//                             color: Colors.grey[200],
//                             child:
//                                 selectedType == "photo" && pickedMedia != null
//                                 ? Image.memory(fileBytes!, fit: BoxFit.cover)
//                                 : Center(
//                                     child: Text(
//                                       pickedFile?.name ??
//                                           pickedMedia?.name ??
//                                           "Preview",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: const Text("Cancel"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         try {
//                           // --- Validation ---
//                           if ((pickedMedia == null && pickedFile == null) ||
//                               titleCtrl.text.trim().isEmpty ||
//                               priceCtrl.text.trim().isEmpty) {
//                             Get.snackbar(
//                               "Error",
//                               "Please select a file and fill in title & price",
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.redAccent,
//                               colorText: Colors.white,
//                             );
//                             return;
//                           }

//                           final user = FirebaseAuth.instance.currentUser;
//                           if (user == null) return;

//                           final price =
//                               double.tryParse(priceCtrl.text.trim()) ?? 0.0;

//                           Uint8List? bytes = pickedMedia != null
//                               ? await pickedMedia!.readAsBytes()
//                               : pickedFile?.bytes;

//                           if (bytes == null || bytes.isEmpty) {
//                             Get.snackbar(
//                               "Error",
//                               "File data is missing",
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.redAccent,
//                               colorText: Colors.white,
//                             );
//                             return;
//                           }

//                           // --- Upload to Firebase Storage ---
//                           final fileName =
//                               pickedFile?.name ?? pickedMedia?.name ?? "file";
//                           final storageRef = FirebaseStorage.instance
//                               .ref()
//                               .child("media_items/${user.uid}/$fileName");

//                           final snapshot = await storageRef.putData(bytes);
//                           final downloadUrl = await snapshot.ref
//                               .getDownloadURL();

//                           // --- Create MediaItem ---
//                           final newItem = MediaItem(
//                             title: titleCtrl.text.trim(),
//                             author: authController.fullName.value.isNotEmpty
//                                 ? authController.fullName.value
//                                 : "@Unknown",

//                             price: price,
//                             views: 0,
//                             rating: 0.0,
//                             isVerified: false,
//                             category: selectedType,
//                             mediaType: selectedType,
//                             imageUrl: selectedType == "photo"
//                                 ? downloadUrl
//                                 : null,
//                           );

//                           // --- Save to Firestore (consistent collection) ---
//                           // داخل زر Save فقط (بدون تغيير UI)

//                           await FirebaseFirestore.instance
//                               .collection("media_items")
//                               .add({
//                                 "title": newItem.title,
//                                 "author": newItem.author,
//                                 "price": newItem.price,
//                                 "views": 0,
//                                 "rating": 0.0,
//                                 "imageUrl": newItem.imageUrl,
//                                 "downloadUrl": downloadUrl,
//                                 "timestamp": FieldValue.serverTimestamp(),
//                                 "userId": user.uid,
//                                 "category": newItem.category,
//                                 "mediaType": newItem.mediaType,
//                                 "license": "Standard",
//                                 "keywords": newItem.title.toLowerCase().split(
//                                   " ",
//                                 ),
//                               });

//                           // 🔥 UPDATE UI INSTANTLY
//                           controller.featuredMedia.insert(0, newItem);
//                           controller.discoverMedia.insert(0, newItem);

//                           Get.back();
//                           Get.snackbar(
//                             "Success",
//                             "Media uploaded successfully",
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: Colors.green,
//                             colorText: Colors.white,
//                           );
//                         } catch (e, st) {
//                           print("Upload error: $e\n$st");
//                           Get.snackbar(
//                             "Error",
//                             "Failed to upload media: $e",
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: Colors.redAccent,
//                             colorText: Colors.white,
//                           );
//                         }
//                       },
//                       child: const Text("Save"),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//         backgroundColor: Colors.pinkAccent,
//         child: const Icon(Icons.upload, color: Colors.white),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 1200),
//                 padding: const EdgeInsets.all(24),
//                 child: buildMainContent(context),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_source_you/model/media_item.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';
import 'package:we_source_you/view/media_market/widgets/main_content.dart';

class MediaView extends StatelessWidget {
  MediaView({super.key});
  final controller = Get.find<MediaController>();
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(controller, authController),
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.upload, color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(24),
                child: buildMainContent(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showUploadDialog(
    MediaController controller,
    AuthController authController,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "You must sign in before uploading.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String selectedType = "photo";
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    XFile? pickedMedia;
    PlatformFile? pickedFile;
    Uint8List? fileBytes;
    bool isUploading = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          void safeSetState(VoidCallback fn) {
            if (context.mounted) setState(fn);
          }

          return WillPopScope(
            onWillPop: () async => !isUploading,
            child: AlertDialog(
              title: const Text("Upload Media"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUploading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Uploading... Please wait"),
                          ],
                        ),
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: ["photo", "video", "audio", "document", "other"]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.capitalize!),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            safeSetState(() {
                              selectedType = val;
                              pickedMedia = null;
                              pickedFile = null;
                              fileBytes = null;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: "Media Type",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: "Price"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Pick File"),
                        onPressed: () async {
                          if (selectedType == "photo" ||
                              selectedType == "video") {
                            final picker = ImagePicker();
                            final file = selectedType == "photo"
                                ? await picker.pickImage(
                                    source: ImageSource.gallery,
                                  )
                                : await picker.pickVideo(
                                    source: ImageSource.gallery,
                                  );
                            if (file != null) {
                              final bytes = await file.readAsBytes();
                              safeSetState(() {
                                pickedMedia = file;
                                fileBytes = bytes;
                              });
                            }
                          } else {
                            final result = await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              withData: true,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              safeSetState(() {
                                pickedFile = result.files.first;
                                fileBytes = pickedFile!.bytes;
                              });
                            }
                          }
                        },
                      ),
                      if (fileBytes != null)
                        Container(
                          width: double.infinity,
                          height: selectedType == "photo" ? 150 : 100,
                          color: Colors.grey[200],
                          child: selectedType == "photo" && pickedMedia != null
                              ? Image.memory(fileBytes!, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    pickedFile?.name ??
                                        pickedMedia?.name ??
                                        "Preview",
                                  ),
                                ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: isUploading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if ((pickedMedia == null && pickedFile == null) ||
                              titleCtrl.text.isEmpty ||
                              priceCtrl.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please select a file and fill title & price",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          final price =
                              double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                          final bytes = pickedMedia != null
                              ? await pickedMedia!.readAsBytes()
                              : pickedFile?.bytes;

                          if (bytes == null || bytes.isEmpty) return;

                          safeSetState(() => isUploading = true);

                          try {
                            final fileName =
                                pickedFile?.name ??
                                pickedMedia?.name ??
                                "file_${DateTime.now().millisecondsSinceEpoch}";
                            final storageRef = FirebaseStorage.instance
                                .ref()
                                .child("media_items/${user.uid}/$fileName");
                            final snapshot = await storageRef.putData(bytes);
                            final downloadUrl = await snapshot.ref
                                .getDownloadURL();

                            final newItem = MediaItem(
                              title: titleCtrl.text.trim(),
                              author: authController.fullName.value.isNotEmpty
                                  ? authController.fullName.value
                                  : "@Unknown",
                              price: price,
                              views: 0,
                              rating: 0.0,
                              isVerified: false,
                              category: selectedType,
                              mediaType: selectedType,
                              imageUrl: selectedType == "photo"
                                  ? downloadUrl
                                  : null,
                            );

                            await FirebaseFirestore.instance
                                .collection("media_items")
                                .add({
                                  "title": newItem.title,
                                  "author": newItem.author,
                                  "price": newItem.price,
                                  "views": 0,
                                  "rating": 0.0,
                                  "imageUrl": newItem.imageUrl,
                                  "downloadUrl": downloadUrl,
                                  "timestamp": FieldValue.serverTimestamp(),
                                  "userId": user.uid,
                                  "category": newItem.category,
                                  "mediaType": newItem.mediaType,
                                  "license": "Standard",
                                  "keywords": newItem.title.toLowerCase().split(
                                    " ",
                                  ),
                                });

                            controller.featuredMedia.insert(0, newItem);
                            controller.discoverMedia.insert(0, newItem);

                            if (context.mounted) {
                              Get.back();
                              Get.snackbar(
                                "Success",
                                "Media uploaded successfully",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            safeSetState(() => isUploading = false);
                            Get.snackbar(
                              "Error",
                              "Failed to upload: $e",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
            ),
          );
        },
      ),
      barrierDismissible: false,
    ).then((_) {
      titleCtrl.dispose();
      priceCtrl.dispose();
    });
  }
}

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:we_source_you/model/media_item.dart';
// import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';
// import 'package:we_source_you/view/media_market/widgets/main_content.dart';

// class MediaView extends GetView<MediaController> {
//   const MediaView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showUploadDialog(controller, authController),
//         backgroundColor: Colors.pinkAccent,
//         child: const Icon(Icons.upload, color: Colors.white),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 1200),
//                 padding: const EdgeInsets.all(24),
//                 child: buildMainContent(context),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _showUploadDialog(
//     MediaController controller,
//     AuthController authController,
//   ) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       Get.snackbar(
//         "Error",
//         "You must sign in before uploading.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     // 1. Initialize variables outside
//     String selectedType = "photo";
//     final titleCtrl = TextEditingController();
//     final priceCtrl = TextEditingController();
//     XFile? pickedMedia;
//     PlatformFile? pickedFile;
//     Uint8List? fileBytes;
//     bool isUploading = false; // To show loading spinner

//     // 2. Open Dialog
//     await Get.dialog(
//       StatefulBuilder(
//         builder: (context, setState) {
//           // Helper to safely update UI
//           void safeSetState(VoidCallback fn) {
//             if (context.mounted) {
//               setState(fn);
//             }
//           }

//           return PopScope(
//             // Prevent closing via back button while uploading
//             canPop: !isUploading,
//             child: AlertDialog(
//               title: const Text("Upload Media"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (isUploading)
//                       const Padding(
//                         padding: EdgeInsets.all(20.0),
//                         child: Column(
//                           children: [
//                             CircularProgressIndicator(),
//                             SizedBox(height: 10),
//                             Text("Uploading... Please wait"),
//                           ],
//                         ),
//                       )
//                     else ...[
//                       DropdownButtonFormField<String>(
//                         value: selectedType,
//                         items: ["photo", "video", "audio", "document", "other"]
//                             .map(
//                               (e) => DropdownMenuItem(
//                                 value: e,
//                                 child: Text(e.capitalize!),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (val) {
//                           if (val != null) {
//                             safeSetState(() {
//                               selectedType = val;
//                               pickedMedia = null;
//                               pickedFile = null;
//                               fileBytes = null;
//                             });
//                           }
//                         },
//                         decoration: const InputDecoration(
//                           labelText: "Media Type",
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: titleCtrl,
//                         decoration: const InputDecoration(labelText: "Title"),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: priceCtrl,
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         decoration: const InputDecoration(labelText: "Price"),
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.attach_file),
//                         label: const Text("Pick File"),
//                         onPressed: () async {
//                           // File Picking Logic
//                           if (selectedType == "photo" ||
//                               selectedType == "video") {
//                             final picker = ImagePicker();
//                             final file = selectedType == "photo"
//                                 ? await picker.pickImage(
//                                     source: ImageSource.gallery,
//                                   )
//                                 : await picker.pickVideo(
//                                     source: ImageSource.gallery,
//                                   );

//                             if (file != null) {
//                               final bytes = await file.readAsBytes();
//                               // Check mounted before updating state
//                               safeSetState(() {
//                                 fileBytes = bytes;
//                                 pickedMedia = file;
//                               });
//                             }
//                           } else {
//                             final result = await FilePicker.platform.pickFiles(
//                               allowMultiple: false,
//                               withData: true,
//                             );
//                             if (result != null && result.files.isNotEmpty) {
//                               safeSetState(() {
//                                 pickedFile = result.files.first;
//                                 fileBytes = pickedFile!.bytes;
//                               });
//                             }
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       if (fileBytes != null)
//                         Container(
//                           width: double.infinity,
//                           height: selectedType == "photo" ? 150 : 100,
//                           color: Colors.grey[200],
//                           child: selectedType == "photo" && pickedMedia != null
//                               ? Image.memory(fileBytes!, fit: BoxFit.cover)
//                               : Center(
//                                   child: Text(
//                                     pickedFile?.name ??
//                                         pickedMedia?.name ??
//                                         "Preview",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                     ],
//                   ],
//                 ),
//               ),
//               actions: isUploading
//                   ? [] // Hide buttons while uploading
//                   : [
//                       TextButton(
//                         onPressed: () => Get.back(),
//                         child: const Text("Cancel"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           // --- Validation ---
//                           if ((pickedMedia == null && pickedFile == null) ||
//                               titleCtrl.text.trim().isEmpty ||
//                               priceCtrl.text.trim().isEmpty) {
//                             Get.snackbar(
//                               "Error",
//                               "Please select a file and fill in title & price",
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.redAccent,
//                               colorText: Colors.white,
//                             );
//                             return;
//                           }

//                           final price =
//                               double.tryParse(priceCtrl.text.trim()) ?? 0.0;

//                           // Prepare bytes
//                           Uint8List? bytes = pickedMedia != null
//                               ? await pickedMedia!.readAsBytes()
//                               : pickedFile?.bytes;

//                           if (bytes == null || bytes.isEmpty) {
//                             Get.snackbar(
//                               "Error",
//                               "File data is missing",
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.redAccent,
//                               colorText: Colors.white,
//                             );
//                             return;
//                           }

//                           // Start Uploading state
//                           safeSetState(() {
//                             isUploading = true;
//                           });

//                           try {
//                             // --- Upload to Firebase Storage ---
//                             final fileName =
//                                 pickedFile?.name ??
//                                 pickedMedia?.name ??
//                                 "file_${DateTime.now().millisecondsSinceEpoch}";

//                             final storageRef = FirebaseStorage.instance
//                                 .ref()
//                                 .child("media_items/${user!.uid}/$fileName");

//                             final snapshot = await storageRef.putData(bytes);
//                             final downloadUrl = await snapshot.ref
//                                 .getDownloadURL();

//                             // --- Create MediaItem ---
//                             final newItem = MediaItem(
//                               title: titleCtrl.text.trim(),
//                               author: authController.fullName.value.isNotEmpty
//                                   ? authController.fullName.value
//                                   : "@Unknown",
//                               price: price,
//                               views: 0,
//                               rating: 0.0,
//                               isVerified: false,
//                               category: selectedType,
//                               mediaType: selectedType,
//                               imageUrl: selectedType == "photo"
//                                   ? downloadUrl
//                                   : null,
//                             );

//                             // --- Save to Firestore ---
//                             await FirebaseFirestore.instance
//                                 .collection("media_items")
//                                 .add({
//                                   "title": newItem.title,
//                                   "author": newItem.author,
//                                   "price": newItem.price,
//                                   "views": 0,
//                                   "rating": 0.0,
//                                   "imageUrl": newItem.imageUrl,
//                                   "downloadUrl": downloadUrl,
//                                   "timestamp": FieldValue.serverTimestamp(),
//                                   "userId": user.uid,
//                                   "category": newItem.category,
//                                   "mediaType": newItem.mediaType,
//                                   "license": "Standard",
//                                   "keywords": newItem.title.toLowerCase().split(
//                                     " ",
//                                   ),
//                                 });

//                             // --- Update UI ---
//                             controller.featuredMedia.insert(0, newItem);
//                             controller.discoverMedia.insert(0, newItem);

//                             // Close dialog on success
//                             if (context.mounted) {
//                               Get.back();
//                               Get.snackbar(
//                                 "Success",
//                                 "Media uploaded successfully",
//                                 snackPosition: SnackPosition.BOTTOM,
//                                 backgroundColor: Colors.green,
//                                 colorText: Colors.white,
//                               );
//                             }
//                           } catch (e) {
//                             print("Upload error: $e");
//                             // Stop loading state on error
//                             safeSetState(() {
//                               isUploading = false;
//                             });

//                             Get.snackbar(
//                               "Error",
//                               "Failed to upload media: $e",
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.redAccent,
//                               colorText: Colors.white,
//                             );
//                           }
//                         },
//                         child: const Text("Save"),
//                       ),
//                     ],
//             ),
//           );
//         },
//       ),
//       barrierDismissible: false, // Prevent clicking outside to close
//     ).then((_) {
//       // 3. Safe Cleanup runs when dialog closes (Cancel or Save)
//       titleCtrl.dispose();
//       priceCtrl.dispose();
//     });
//   }
// }
