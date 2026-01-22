// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/kyc_controller.dart';

// class KycView extends StatelessWidget {
//   final KycController controller = Get.put(KycController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Identity Verification")),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         String status = controller.userStatus.value;

//         if (status == 'approved') {
//           return _buildStatus(
//             Icons.check_circle,
//             Colors.green,
//             "Verified",
//             "Your account is fully approved.",
//           );
//         }

//         if (status == 'manual_review') {
//           return _buildStatus(
//             Icons.hourglass_bottom,
//             Colors.orange,
//             "Under Review",
//             "Your documents are being reviewed manually by our team.",
//           );
//         }

//         if (status == 'rejected') {
//           return _buildStatus(
//             Icons.error,
//             Colors.red,
//             "Rejected",
//             "Verification failed. Please contact support.",
//           );
//         }

//         // Default: Pending / None
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.shield, size: 80, color: Colors.blue),
//               const SizedBox(height: 20),
//               const Text(
//                 "Verify your Identity",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   "To comply with regulations, please verify your ID.",
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () => controller.startSumsubVerification(),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 15,
//                   ),
//                 ),
//                 child: const Text("Start Verification"),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildStatus(IconData icon, Color color, String title, String msg) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 80, color: color),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(msg, textAlign: TextAlign.center),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/kyc/controllers/kyc_controller.dart';

class KycView extends StatelessWidget {
  final controller = Get.put(KycController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          return ElevatedButton(
            onPressed: controller.startKyc,
            child: const Text('Start Verification'),
          );
        }),
      ),
    );
  }
}
