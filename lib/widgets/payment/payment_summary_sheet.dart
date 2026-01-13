// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/services/payment_controller.dart';
// import 'package:we_source_you/widgets/payment/payment_method_selector.dart';

// class PaymentSummarySheet extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final double amount;
//   final String? mediaType;
//   final VoidCallback onConfirm;

//   const PaymentSummarySheet({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.amount,
//     this.mediaType,
//     required this.onConfirm,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PaymentController>();
//     final platformFee = controller.calculatePlatformFee(amount);
//     final total = controller.calculateTotal(amount);

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Payment Summary',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Get.back(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Item Details
//           _SummaryRow(label: 'Item', value: title),
//           if (subtitle.isNotEmpty) _SummaryRow(label: 'Details', value: subtitle),
//           if (mediaType != null) _SummaryRow(label: 'Type', value: mediaType!),
//           const Divider(height: 32),

//           // Pricing Breakdown
//           _SummaryRow(label: 'Amount', value: '\$${amount.toStringAsFixed(2)}'),
//           _SummaryRow(
//             label: 'Platform Fee (15%)',
//             value: '\$${platformFee.toStringAsFixed(2)}',
//           ),
//           const Divider(height: 32),
//           _SummaryRow(
//             label: 'Total',
//             value: '\$${total.toStringAsFixed(2)}',
//             isTotal: true,
//           ),

//           const SizedBox(height: 24),

//           // Payment Method Selector
//           const PaymentMethodSelector(),

//           const SizedBox(height: 24),

//           // Confirm Button
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: controller.isProcessing.value ? null : onConfirm,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: controller.isProcessing.value
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Confirm Payment',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool isTotal;

//   const _SummaryRow({
//     required this.label,
//     required this.value,
//     this.isTotal = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.black : Colors.grey.shade700,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isTotal ? 20 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.blue : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
