// import 'dart:html';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/kyc/controllers/kyc_controller.dart';

// class KYCUploadPage extends StatelessWidget {
//   final KYCController controller = Get.put(KYCController());

//   File? idFile;
//   File? selfieFile;
//   File? otherFile;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 'KYC Verification',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 10),
//             // ✅ Upload ID
//             ElevatedButton(
//               onPressed: () {
//                 final uploadInput = FileUploadInputElement()
//                   ..accept = 'image/*';
//                 uploadInput.click();
//                 uploadInput.onChange.listen((e) {
//                   final files = uploadInput.files;
//                   if (files != null && files.isNotEmpty) {
//                     idFile = files[0];

//                     final reader = FileReader();
//                     reader.readAsDataUrl(idFile!);
//                     reader.onLoadEnd.listen((e) {
//                       controller.idPreview.value = reader.result as String;
//                     });
//                   }
//                 });
//               },
//               child: Text('Upload ID'),
//             ),
//             Obx(
//               () => controller.idPreview.value != ''
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Image.network(
//                         controller.idPreview.value,
//                         height: 120,
//                       ),
//                     )
//                   : SizedBox.shrink(),
//             ),

//             // ✅ Upload Selfie
//             ElevatedButton(
//               onPressed: () {
//                 final uploadInput = FileUploadInputElement()
//                   ..accept = 'image/*';
//                 uploadInput.click();
//                 uploadInput.onChange.listen((e) {
//                   final files = uploadInput.files;
//                   if (files != null && files.isNotEmpty) {
//                     selfieFile = files[0];

//                     final reader = FileReader();
//                     reader.readAsDataUrl(selfieFile!);
//                     reader.onLoadEnd.listen((e) {
//                       controller.selfiePreview.value = reader.result as String;
//                     });
//                   }
//                 });
//               },
//               child: Text('Upload Selfie'),
//             ),
//             Obx(
//               () => controller.selfiePreview.value != ''
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Image.network(
//                         controller.selfiePreview.value,
//                         height: 120,
//                       ),
//                     )
//                   : SizedBox.shrink(),
//             ),
//             // ✅ Upload Other Document (Optional)
//             ElevatedButton(
//               onPressed: () {
//                 final uploadInput = FileUploadInputElement()
//                   ..accept = 'image/*';
//                 uploadInput.click();
//                 uploadInput.onChange.listen((e) {
//                   final files = uploadInput.files;
//                   if (files != null && files.isNotEmpty) {
//                     otherFile = files[0];

//                     final reader = FileReader();
//                     reader.readAsDataUrl(otherFile!);
//                     reader.onLoadEnd.listen((e) {
//                       controller.otherPreview.value = reader.result as String;
//                     });
//                   }
//                 });
//               },
//               child: Text('Upload Other Document (Optional)'),
//             ),
//             Obx(
//               () => controller.otherPreview.value != ''
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Image.network(
//                         controller.otherPreview.value,
//                         height: 120,
//                       ),
//                     )
//                   : SizedBox.shrink(),
//             ),

//             const SizedBox(height: 20),
//             // ✅ Submit Button
//             Obx(
//               () => ElevatedButton(
//                 style: ButtonStyle(
//                   minimumSize: WidgetStateProperty.all(
//                     Size(double.infinity, 50),
//                   ),
//                   backgroundColor: WidgetStateProperty.resolveWith<Color>((
//                     states,
//                   ) {
//                     if (states.contains(MaterialState.disabled))
//                       return Colors.grey;
//                     return Colors.blue;
//                   }),
//                 ),
//                 onPressed:
//                     (controller.idPreview.value != '' &&
//                         controller.selfiePreview.value != '' &&
//                         !controller.isLoading.value)
//                     ? () async {
//                         await controller.uploadKYC(
//                           idFile!,
//                           selfieFile!,
//                           otherFile,
//                         );
//                         if (controller.errorMessage.value == '') {
//                           Get.snackbar(
//                             'Success',
//                             'KYC submitted successfully!',
//                           );
//                         }
//                       }
//                     : null,
//                 child: controller.isLoading.value
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text('Submit KYC', style: TextStyle(fontSize: 16)),
//               ),
//             ),

//             const SizedBox(height: 10),
//             Obx(
//               () => controller.errorMessage.value != ''
//                   ? Text(
//                       controller.errorMessage.value,
//                       style: TextStyle(color: Colors.red),
//                     )
//                   : SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/kyc/controllers/kyc_controller.dart';

class KYCUploadPage extends StatelessWidget {
  KYCUploadPage({super.key});

  final KYCController controller = Get.put(KYCController());

  File? idFile;
  File? selfieFile;
  File? otherFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
          desktop: _buildDesktop(context),
        ),
      ),
    );
  }

  /// ---------------- MOBILE ----------------
  Widget _buildMobile(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(16),
        child: _buildKYCContent(context),
      ),
    );
  }

  /// ---------------- TABLET ----------------
  Widget _buildTablet(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(32),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(24),
        child: _buildKYCContent(context),
      ),
    );
  }

  /// ---------------- DESKTOP ----------------
  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.all(40),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(32),
        child: _buildKYCContent(context),
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

  // ================= CONTENT =================
  Widget _buildKYCContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- HEADER ----------
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 8),
              const Text(
                'KYC Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// ---------- UPLOAD ID ----------
          _uploadButton(
            title: 'Upload First Side OF ID',
            onPick: (file, preview) {
              idFile = file;
              controller.idPreview.value = preview;
            },
          ),
          _previewImage(controller.idPreview, () {
            idFile = null;
            controller.idPreview.value = '';
          }),
          const SizedBox(height: 16),

          /// ---------- UPLOAD SELFIE ----------
          _uploadButton(
            title: 'Upload Second Side OF ID',
            onPick: (file, preview) {
              selfieFile = file;
              controller.selfiePreview.value = preview;
            },
          ),
          _previewImage(controller.selfiePreview, () {
            selfieFile = null;
            controller.selfiePreview.value = '';
          }),
          const SizedBox(height: 16),

          /// ---------- UPLOAD OTHER ----------
          _uploadButton(
            title: 'Upload Selfie With ID ',
            onPick: (file, preview) {
              otherFile = file;
              controller.otherPreview.value = preview;
            },
          ),
          _previewImage(controller.otherPreview, () {
            otherFile = null;
            controller.otherPreview.value = '';
          }),
          const SizedBox(height: 32),

          /// ---------- SUBMIT ----------
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (controller.idPreview.value.isNotEmpty &&
                        controller.selfiePreview.value.isNotEmpty &&
                        controller.otherPreview.value.isNotEmpty &&
                        !controller.isLoading.value)
                    ? () async {
                        await controller.uploadKYC(
                          idFile!,
                          selfieFile!,
                          otherFile,
                        );

                        if (controller.errorMessage.value.isEmpty) {
                          Get.back();
                          Get.snackbar(
                            'Success',
                            'KYC submitted successfully!',
                          );
                        }
                      }
                    : null,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit KYC', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ---------- ERROR ----------
          Obx(
            () => controller.errorMessage.value.isNotEmpty
                ? Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _uploadButton({
    required String title,
    required Function(File file, String preview) onPick,
  }) {
    return ElevatedButton(
      onPressed: () {
        final uploadInput = FileUploadInputElement()..accept = 'image/*';
        uploadInput.click();
        uploadInput.onChange.listen((_) {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files[0];
            final reader = FileReader();
            reader.readAsDataUrl(file);
            reader.onLoadEnd.listen((_) {
              onPick(file, reader.result as String);
            });
          }
        });
      },
      child: Text(title),
    );
  }

  Widget _previewImage(RxString preview, void Function() onDelete) {
    return Obx(
      () => preview.value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                children: [
                  // الصورة المعاينة
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      preview.value,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // زر الحذف (X)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
