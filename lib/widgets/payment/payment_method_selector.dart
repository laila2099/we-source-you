// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/services/payment_controller.dart';
// import 'package:we_source_you/model/payment_models.dart';

// class PaymentMethodSelector extends StatelessWidget {
//   const PaymentMethodSelector({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PaymentController>();

//     return Obx(() => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Payment Method',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _PaymentMethodCard(
//                     method: PaymentMethod.stripe,
//                     icon: Icons.credit_card,
//                     label: 'Stripe',
//                     isSelected: controller.selectedPaymentMethod.value ==
//                         PaymentMethod.stripe,
//                     onTap: () =>
//                         controller.selectedPaymentMethod.value =
//                             PaymentMethod.stripe,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _PaymentMethodCard(
//                     method: PaymentMethod.paypal,
//                     icon: Icons.payment,
//                     label: 'PayPal',
//                     isSelected: controller.selectedPaymentMethod.value ==
//                         PaymentMethod.paypal,
//                     onTap: () =>
//                         controller.selectedPaymentMethod.value =
//                             PaymentMethod.paypal,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ));
//   }
// }

// class _PaymentMethodCard extends StatelessWidget {
//   final PaymentMethod method;
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _PaymentMethodCard({
//     required this.method,
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           color: isSelected ? Colors.blue.shade50 : Colors.white,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: 32,
//               color: isSelected ? Colors.blue : Colors.grey,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? Colors.blue : Colors.black87,
//               ),
//             ),
//             if (isSelected)
//               const Padding(
//                 padding: EdgeInsets.only(top: 4),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 20,
//                   color: Colors.blue,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
