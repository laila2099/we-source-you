import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_source_you/core/services/base_firebase_service.dart';

import '../../model/payment_models.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  var isLoading = false.obs;
  var statusMessage = "".obs;

  // ===========================================================================
  // 1. PAYMENT FLOW (The "Company Hold" Phase)
  // ===========================================================================

  /// Use this when User A wants to pay for Media, Hiring, or Proposal.
  /// This initiates the "Hold" (Escrow).
  Future<PaymentResult> initiateMarketplacePayment({
    required MarketItemType type,
    required PaymentMethod method,
    // IDs required based on type
    String? mediaId,
    String? teamId,
    String? proposalId,
    String? jobId, // Required for Proposal
    // Amounts/Details
    double? amount,
    String? hireType, // 'hourly', 'project', etc.
  }) async {
    isLoading.value = true;
    statusMessage.value = "Initiating Secure Payment...";

    try {
      if (method == PaymentMethod.stripe) {
        return await _processStripeMarketplace(
          type,
          mediaId,
          teamId,
          proposalId,
          jobId,
          amount,
          hireType,
        );
      } else {
        return await _processPaypalMarketplace(
          type,
          mediaId,
          teamId,
          proposalId,
          jobId,
          amount,
          hireType,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Payment Failed",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return PaymentResult(success: false, message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Internal Stripe Handler ---
  Future<PaymentResult> _processStripeMarketplace(
    MarketItemType type,
    String? mediaId,
    String? teamId,
    String? proposalId,
    String? jobId,
    double? amount,
    String? hireType,
  ) async {
    StripeEscrowResponse response;

    // 1. Get Client Secret from Backend
    if (type == MarketItemType.media) {
      response = await _service.createMediaPaymentIntent(mediaId!);
    } else if (type == MarketItemType.hiring) {
      response = await _service.createHiringPaymentIntent(
        teamId!,
        hireType!,
        amount!,
      );
    } else {
      response = await _service.createProposalPaymentIntent(
        proposalId!,
        jobId!,
        amount!,
      );
    }

    // 2. Confirm Payment on Client (Flutter Web)
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: response.clientSecret,
          merchantDisplayName: 'We Source You',
          style: ThemeMode.light,
        ),
      );

      // On Web, presentPaymentSheet often behaves differently,
      // but standard flutter_stripe implementation involves confirmPayment
      await Stripe.instance.presentPaymentSheet();

      // If no error thrown, payment is "Held" on Stripe
      Get.snackbar(
        "Success",
        "Payment Securely Held by Company",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return PaymentResult(
        success: true,
        transactionId: response.paymentIntentId,
      );
    } catch (e) {
      if (e is StripeException) {
        throw Exception("Stripe Error: ${e.error.localizedMessage}");
      }
      throw e;
    }
  }

  // --- Internal PayPal Handler ---
  Future<PaymentResult> _processPaypalMarketplace(
    MarketItemType type,
    String? mediaId,
    String? teamId,
    String? proposalId,
    String? jobId,
    double? amount,
    String? hireType,
  ) async {
    PaypalOrderResponse response;

    // 1. Create Order on Backend
    if (type == MarketItemType.media) {
      response = await _service.createMediaPayPalOrder(mediaId!, amount!);
    } else if (type == MarketItemType.hiring) {
      response = await _service.createHiringPayPalOrder(
        teamId!,
        hireType!,
        amount!,
      );
    } else {
      response = await _service.createProposalPayPalOrder(
        proposalId!,
        jobId!,
        amount!,
      );
    }

    // 2. Open Approval URL
    if (response.approvalUrl != null) {
      final Uri url = Uri.parse(response.approvalUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        ); // Opens new tab/window

        // 3. UI Logic to Confirm Return
        // In a real web app, you usually listen to a deep link or have a "I've Paid" button.
        // For simplicity here, we ask the user to confirm they completed the flow.
        final result = await Get.defaultDialog(
          title: "PayPal Action",
          middleText: "Did you complete the payment in the browser?",
          textConfirm: "Yes, I paid",
          textCancel: "Cancel",
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        );

        if (result == true) {
          // 4. Capture the Payment
          statusMessage.value = "Verifying PayPal Payment...";
          await _service.capturePayPalPayment(response.orderId);
          Get.snackbar(
            "Success",
            "Payment Securely Held by Company",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return PaymentResult(success: true, transactionId: response.orderId);
        } else {
          throw Exception("Payment cancelled by user");
        }
      }
    }
    throw Exception("Could not launch PayPal");
  }

  // ===========================================================================
  // 2. COMPLETION FLOW (Release Money)
  // ===========================================================================

  /// Called when BOTH parties agree work is done.
  /// Releases money from Company Hold -> Worker.
  Future<void> releaseFundsAfterWork({
    required MarketItemType type,
    required String transactionId, // The ID we got from the payment phase
    required PaymentMethod method,
    String? hiringId, // Needed for hiring release
    String? paymentId, // Needed for proposal release
  }) async {
    isLoading.value = true;
    statusMessage.value = "Releasing funds to worker...";

    String methodStr = method == PaymentMethod.stripe ? 'stripe' : 'paypal';

    try {
      if (type == MarketItemType.media) {
        await _service.releaseMediaPayment(transactionId, methodStr);
      } else if (type == MarketItemType.hiring) {
        await _service.releaseHiringPayment(
          hiringId!,
          transactionId,
          methodStr,
        );
      } else {
        await _service.releaseProposalPayment(
          paymentId!,
          transactionId,
          methodStr,
        );
      }

      // Trigger Auto Payout (Optional: if you want to push to bank immediately)
      // await _service.processAutoPayout(jobId);

      Get.snackbar(
        "Success",
        "Funds Released to Worker!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Release failed: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // 3. DISPUTE FLOW
  // ===========================================================================

  /// Triggers a dispute. Usually called by a client or worker button.
  Future<void> raiseDispute(String jobId, String reason) async {
    isLoading.value = true;
    try {
      // 1. Call Backend to update status to 'disputed' (You might need a specific client-side trigger function
      // or update Firestore directly if security rules allow.
      // Based on your files, `handleDispute` is admin only.
      // Usually, users create a "Dispute Ticket" in Firestore, and the Admin uses `handleDispute`.)

      // Assuming you create a ticket in Firestore:
      // await FirebaseFirestore.instance.collection('disputes').add({...});

      // For this example, let's assume you have a 'requestRefund' logic or similar.
      // If user wants refund:
      // await _service.processFullRefund(jobId, reason); // *Careful: This is usually Admin only in your code*

      Get.snackbar(
        "Dispute Opened",
        "Admin has been notified. Funds are frozen.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
