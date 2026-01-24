import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/kyc/controllers/kyc_controller.dart';

class KYCUploadPage extends StatelessWidget {
  final KYCController controller = Get.put(KYCController());

  File? idFile;
  File? selfieFile;
  File? otherFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              final uploadInput = FileUploadInputElement()..accept = 'image/*';
              uploadInput.click();
              uploadInput.onChange.listen((e) {
                final files = uploadInput.files;
                if (files != null && files.isNotEmpty) idFile = files[0];
              });
            },
            child: Text('Upload ID'),
          ),
          ElevatedButton(
            onPressed: () {
              final uploadInput = FileUploadInputElement()..accept = 'image/*';
              uploadInput.click();
              uploadInput.onChange.listen((e) {
                final files = uploadInput.files;
                if (files != null && files.isNotEmpty) selfieFile = files[0];
              });
            },
            child: Text('Upload Selfie'),
          ),
          ElevatedButton(
            onPressed: () {
              final uploadInput = FileUploadInputElement()..accept = 'image/*';
              uploadInput.click();
              uploadInput.onChange.listen((e) {
                final files = uploadInput.files;
                if (files != null && files.isNotEmpty) otherFile = files[0];
              });
            },
            child: Text('Upload Other Document (Optional)'),
          ),
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed:
                  (idFile != null &&
                      selfieFile != null &&
                      !controller.isLoading.value)
                  ? () async {
                      await controller.uploadKYC(
                        idFile!,
                        selfieFile!,
                        otherFile,
                      );
                      if (controller.errorMessage.value == '') {
                        Get.snackbar('Success', 'KYC submitted successfully!');
                      }
                    }
                  : null,
              child: controller.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit KYC'),
            ),
          ),
          Obx(
            () => controller.errorMessage.value != ''
                ? Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
