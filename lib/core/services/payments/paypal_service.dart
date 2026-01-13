// import 'package:we_source_you/core/services/base_firebase_service.dart';

// class PayPalService extends BaseFirebaseService {
//   Future<Map<String, dynamic>> createPaypalEscrow({
//     required String escrowId,
//     required int amount,
//   }) {
//     return call('createPaypalEscrow', {'escrowId': escrowId, 'amount': amount});
//   }

//   Future<void> capturePaypalAuthorization({required String authorizationId}) {
//     return call('capturePaypalAuthorization', {
//       'authorizationId': authorizationId,
//     });
//   }

//   Future<void> releasePaypalPayment({required String escrowId}) {
//     return call('releasePaypalPayment', {'escrowId': escrowId});
//   }
// }
