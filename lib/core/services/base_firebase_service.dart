// import 'package:cloud_functions/cloud_functions.dart';

// abstract class BaseFirebaseService {
//   final FirebaseFunctions functions = FirebaseFunctions.instance;

//   Future<T> call<T>(String functionName, Map<String, dynamic> data) async {
//     try {
//       final result = await functions.httpsCallable(functionName).call(data);
//       return result.data as T;
//     } catch (e) {
//       throw Exception('[$functionName] ${e.toString()}');
//     }
//   }
// }

/*
class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Helper to call functions safely
  Future<T> _call<T>(String name, Map<String, dynamic> data) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return result.data as T;
    } on FirebaseFunctionsException catch (e) {
      throw Exception("${e.code}: ${e.message}");
    } catch (e) {
      throw Exception("System Error: $e");
    }
  }

  // ================== STRIPE GENERIC ==================
  Future<StripeEscrowResponse> createStripeEscrow(
    double amount,
    String jobId,
  ) async {
    final data = await _call('createStripeEscrow', {
      'amount': amount,
      'jobId': jobId,
    });
    return StripeEscrowResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> releaseStripePayment(String jobId) async {
    await _call('releaseStripePayment', {'jobId': jobId});
  }

  // ================== PAYPAL GENERIC ==================
  Future<PaypalOrderResponse> createPaypalEscrow(
    double amount,
    String jobId,
  ) async {
    final data = await _call('createPaypalEscrow', {
      'amount': amount,
      'jobId': jobId,
    });
    return PaypalOrderResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> capturePaypalAuthorization(
    String authorizationId,
    String jobId,
  ) async {
    await _call('capturePaypalAuthorization', {
      'authorizationId': authorizationId,
      'jobId': jobId,
    });
  }

  Future<void> releasePaypalPayment(String jobId) async {
    await _call('releasePaypalPayment', {'jobId': jobId});
  }

  // ================== MARKETPLACE PAYMENTS (CREATE) ==================
  // -- Stripe --
  Future<StripeEscrowResponse> createMediaPaymentIntent(String mediaId) async {
    // Assuming createMediaPaymentIntent exists in your marketplace_payments export
    // If not explicitly in your index.js snippet, use the generic createStripeEscrow
    // BUT based on your files, I'll map what is strictly logically there.
    // *Note: Your index.js exports `createMediaPaymentIntent` from `./marketplace_payments`
    final data = await _call('createMediaPaymentIntent', {'mediaId': mediaId});
    return StripeEscrowResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<StripeEscrowResponse> createHiringPaymentIntent(
    String teamId,
    String hireType,
    double rate,
  ) async {
    final data = await _call('createHiringPaymentIntent', {
      'teamId': teamId,
      'hireType': hireType,
      'rate': rate,
    });
    return StripeEscrowResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<StripeEscrowResponse> createProposalPaymentIntent(
    String proposalId,
    String jobId,
    double amount,
  ) async {
    final data = await _call('createProposalPaymentIntent', {
      'proposalId': proposalId,
      'jobId': jobId,
      'amount': amount,
    });
    return StripeEscrowResponse.fromMap(Map<String, dynamic>.from(data));
  }

  // -- PayPal --
  Future<PaypalOrderResponse> createMediaPayPalOrder(
    String mediaId,
    double amount,
  ) async {
    final data = await _call('createMediaPayPalOrder', {
      'mediaId': mediaId,
      'amount': amount,
    });
    return PaypalOrderResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<PaypalOrderResponse> createHiringPayPalOrder(
    String teamId,
    String hireType,
    double rate,
  ) async {
    final data = await _call('createHiringPayPalOrder', {
      'teamId': teamId,
      'hireType': hireType,
      'rate': rate,
    });
    return PaypalOrderResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<PaypalOrderResponse> createProposalPayPalOrder(
    String proposalId,
    String jobId,
    double amount,
  ) async {
    final data = await _call('createProposalPayPalOrder', {
      'proposalId': proposalId,
      'jobId': jobId,
      'amount': amount,
    });
    return PaypalOrderResponse.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> capturePayPalPayment(String orderId) async {
    await _call('capturePayPalPayment', {'orderId': orderId});
  }

  // ================== MARKETPLACE RELEASES ==================
  Future<void> releaseMediaPayment(
    String transactionId,
    String paymentMethod,
  ) async {
    await _call('releaseMediaPayment', {
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    });
  }

  Future<void> releaseHiringPayment(
    String hiringId,
    String transactionId,
    String paymentMethod,
  ) async {
    await _call('releaseHiringPayment', {
      'hiringId': hiringId,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    });
  }

  Future<void> releaseProposalPayment(
    String paymentId,
    String transactionId,
    String paymentMethod,
  ) async {
    await _call('releaseProposalPayment', {
      'paymentId': paymentId,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    });
  }

  // ================== PAYOUTS ==================
  Future<void> processAutoPayout(String jobId) async {
    await _call('processAutoPayout', {'jobId': jobId});
  }

  // ================== REFUNDS & DISPUTES (ADMIN/AUTO) ==================
  Future<void> processFullRefund(String jobId, String reason) async {
    await _call('processFullRefund', {'jobId': jobId, 'reason': reason});
  }

  Future<void> processPartialRefund(
    String jobId,
    double amount,
    String reason,
  ) async {
    await _call('processPartialRefund', {
      'jobId': jobId,
      'refundAmount': amount,
      'reason': reason,
    });
  }

  Future<void> handleDispute(String jobId, String action, String notes) async {
    await _call('handleDispute', {
      'jobId': jobId,
      'action': action,
      'notes': notes,
    });
  }
}
*/
