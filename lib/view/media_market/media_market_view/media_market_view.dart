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

class MediaView extends GetView<MediaController> {
  MediaView({super.key});

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
                child: MainContent(controller: controller),
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
    String resolution = "High";
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    XFile? pickedMedia;
    PlatformFile? pickedFile;
    Uint8List? fileBytes;
    bool isUploading = false;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
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
                        controller: descriptionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: resolution,
                        items: ["High", "Low"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) safeSetState(() => resolution = val);
                        },
                        decoration: const InputDecoration(
                          labelText: "Resolution",
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if ((pickedMedia == null && pickedFile == null) ||
                              titleCtrl.text.isEmpty ||
                              priceCtrl.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please select a file and fill title, description & price",
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

                            // إنشاء مستند جديد للحصول على ID
                            final docRef = FirebaseFirestore.instance
                                .collection("media_items")
                                .doc();

                            final newItem = MediaItem(
                              id: docRef.id, // حفظ ID
                              title: titleCtrl.text.trim(),
                              author: authController.fullName.value.isNotEmpty
                                  ? authController.fullName.value
                                  : "@Unknown",
                              description: descriptionCtrl.text.trim(),
                              price: price,
                              views: 0,
                              rating: 0.0,
                              ratingCount: 0,
                              isVerified: false,
                              category: selectedType,
                              mediaType: selectedType,
                              imageUrl: selectedType == "photo"
                                  ? downloadUrl
                                  : null,
                            );

                            // رفع البيانات مع ID داخل المستند
                            await docRef.set({
                              "id": docRef.id,
                              "title": newItem.title,
                              "author": newItem.author,
                              "description": newItem.description,
                              "price": newItem.price,
                              "views": 0,
                              "rating": 0.0,
                              "ratingCount": 0,
                              "imageUrl": newItem.imageUrl,
                              "downloadUrl": downloadUrl,
                              "timestamp": FieldValue.serverTimestamp(),
                              "userId": user.uid,
                              "category": newItem.category,
                              "mediaType": newItem.mediaType,
                              "license": "Standard",
                              "resolution": resolution,
                              "keywords": newItem.title.toLowerCase().split(
                                " ",
                              ),
                            });

                            controller.featuredMedia.insert(0, newItem);
                            controller.discoverMedia.insert(0, newItem);

                            if (context.mounted) {
                              Navigator.pop(context);
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
    ).then((_) {
      titleCtrl.dispose();
      descriptionCtrl.dispose();
      priceCtrl.dispose();
    });
  }
}
