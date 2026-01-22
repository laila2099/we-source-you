import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/routes/app_routes.dart';

class AdminDashboard extends StatelessWidget {
  // final AdminKycController controller = Get.put(AdminKycController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin KYC Dashboard")),
      body: TextButton(
        onPressed: () {
          Get.toNamed(AppRoutes.home);
        },
        child: Text("home"),
      ),
      //Obx(() {
      //   if (controller.pendingUsers.isEmpty) {
      //     return const Center(child: Text("No pending manual reviews."));
      //   }

      //   return ListView.builder(
      //     itemCount: controller.pendingUsers.length,
      //     itemBuilder: (context, index) {
      //       final user = controller.pendingUsers[index];
      //       return Card(
      //         margin: const EdgeInsets.all(10),
      //         child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text(
      //                 user.fullName,
      //                 style: const TextStyle(
      //                   fontSize: 18,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               Text("Email: ${user.email}"),
      //               Text(
      //                 "Country: ${user.country}",
      //                 style: TextStyle(
      //                   color: Colors.red[700],
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               Text("Status: ${user.kyc.status}"),
      //               const SizedBox(height: 15),
      //               controller.isLoading.value
      //                   ? const LinearProgressIndicator()
      //                   : Row(
      //                       mainAxisAlignment: MainAxisAlignment.end,
      //                       children: [
      //                         OutlinedButton(
      //                           onPressed: () =>
      //                               controller.reviewUser(user.uid, 'reject'),
      //                           style: OutlinedButton.styleFrom(
      //                             foregroundColor: Colors.red,
      //                           ),
      //                           child: const Text("Reject"),
      //                         ),
      //                         const SizedBox(width: 10),
      //                         ElevatedButton(
      //                           onPressed: () =>
      //                               controller.reviewUser(user.uid, 'approve'),
      //                           style: ElevatedButton.styleFrom(
      //                             backgroundColor: Colors.green,
      //                           ),
      //                           child: const Text("Approve"),
      //                         ),
      //                       ],
      //                     ),
      //             ],
      //           ),
      //         ),
      //       );
      //     },
      //   );
      // }),
    );
  }
}
