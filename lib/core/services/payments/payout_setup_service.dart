import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_routes.dart';

class PayoutSetupService {
  final FirebaseFunctions _fn;

  PayoutSetupService({FirebaseFunctions? functions})
    : _fn = functions ?? FirebaseFunctions.instance;

  Future<void> setPayoutProfilePayPal({required String email}) async {
    await _fn.httpsCallable('setPayoutProfilePayPal').call({'email': email});
  }

  Future<void> openStripeOnboarding({required String baseUrl}) async {
    final returnUrl = '$baseUrl/#${AppRoutes.payoutSettings}?stripe=done';
    final refreshUrl = '$baseUrl/#${AppRoutes.payoutSettings}?stripe=refresh';

    final res = await _fn.httpsCallable('createStripeAccountLink').call({
      'returnUrl': returnUrl,
      'refreshUrl': refreshUrl,
    });

    final data = (res.data is Map) ? Map<String, dynamic>.from(res.data) : {};
    final url = (data['url'] ?? '').toString();
    if (url.isEmpty) throw Exception('Missing Stripe onboarding url');

    final uri = Uri.parse(url);

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_self',
    );

    if (!ok) {
      throw Exception('Could not open Stripe onboarding');
    }
  }
}
