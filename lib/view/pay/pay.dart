// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/services/project_controller.dart';

// class EscrowWebPage extends StatelessWidget {
//   final EscrowController c = Get.put(EscrowController());

//   EscrowWebPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Escrow Payment")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Job / Item: ${c.title.value}",
//               style: const TextStyle(fontSize: 20),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Amount: \$${c.amount.value.toStringAsFixed(2)}",
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),

//             // Payment Method Selection
//             Obx(
//               () => Row(
//                 children: [
//                   ChoiceChip(
//                     label: const Text("Stripe"),
//                     selected: c.selectedMethod.value == PaymentMethod.stripe,
//                     onSelected: (val) =>
//                         c.selectedMethod.value = PaymentMethod.stripe,
//                   ),
//                   const SizedBox(width: 10),
//                   ChoiceChip(
//                     label: const Text("PayPal"),
//                     selected: c.selectedMethod.value == PaymentMethod.paypal,
//                     onSelected: (val) =>
//                         c.selectedMethod.value = PaymentMethod.paypal,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Pay Button
//             Center(
//               child: Obx(
//                 () => ElevatedButton(
//                   onPressed: c.isProcessing.value ? null : c.pay,
//                   child: Text(
//                     c.isProcessing.value ? "Processing..." : "Pay Now",
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Release Button
//             Center(
//               child: Obx(
//                 () => ElevatedButton(
//                   onPressed: c.canRelease() ? c.releasePayment : null,
//                   child: const Text("Release Payment"),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Payment Status
//             Obx(
//               () => Text(
//                 "Payment Status: ${c.getStatusString()}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Obx(
//               () => Text(
//                 "Company Fee: \$${c.companyFee.value.toStringAsFixed(2)}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             Obx(
//               () => Text(
//                 "Worker Amount: \$${c.workerAmount.value.toStringAsFixed(2)}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             Obx(
//               () => Text(
//                 "Refunded Amount: \$${c.refundAmount.value.toStringAsFixed(2)}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             Obx(
//               () => Text(
//                 "Dispute Status: ${c.disputeStatus.value.isEmpty ? "None" : c.disputeStatus.value}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             Obx(
//               () => Text(
//                 "Auto Payout Status: ${c.payoutStatus.value.isEmpty ? "Pending" : c.payoutStatus.value}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/services/payment_controller.dart';
import 'package:we_source_you/model/payment_models.dart';

class JobPaymentScreen extends StatelessWidget {
  final PaymentController controller = Get.put(PaymentController());

  // Variables passed from previous screen
  final String proposalId = "prop_123";
  final String jobId = "job_456";
  final double amount = 150.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Secure Payment")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(controller.statusMessage.value),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Total Amount: \$$amount",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Funds will be held securely by the Company until you approve the work.",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 40),

              // STRIPE BUTTON
              ElevatedButton.icon(
                icon: Icon(Icons.credit_card),
                label: Text("Pay via Card (Stripe)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.all(20),
                ),
                onPressed: () async {
                  PaymentResult result = await controller
                      .initiateMarketplacePayment(
                        type: MarketItemType.proposal,
                        method: PaymentMethod.stripe,
                        proposalId: proposalId,
                        jobId: jobId,
                        amount: amount,
                      );

                  if (result.success) {
                    // Navigate to Chat Screen or wait for Firestore Listener to update UI
                    Get.offNamed('/chat', arguments: {'jobId': jobId});
                  }
                },
              ),

              SizedBox(height: 20),

              // PAYPAL BUTTON
              ElevatedButton.icon(
                icon: Icon(Icons.paypal),
                label: Text("Pay via PayPal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(20),
                ),
                onPressed: () async {
                  PaymentResult result = await controller
                      .initiateMarketplacePayment(
                        type: MarketItemType.proposal,
                        method: PaymentMethod.paypal,
                        proposalId: proposalId,
                        jobId: jobId,
                        amount: amount,
                      );

                  if (result.success) {
                    Get.offNamed('/chat', arguments: {'jobId': jobId});
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
