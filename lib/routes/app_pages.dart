import 'package:get/get.dart';
import 'package:we_source_you/core/middleware/admin_guard.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/admin_dashboard/admin_view/admin_view.dart';
import 'package:we_source_you/view/auth/binding/auth_bindings.dart';
import 'package:we_source_you/view/auth/sign_in/sign_in_view/sign_in_view.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up-view/sign_up_view.dart';
import 'package:we_source_you/view/home/home_view/home_view.dart';
import 'package:we_source_you/view/jobs/apply_job/apply_job.dart';
import 'package:we_source_you/view/jobs/jobs_view/jobs_view.dart';
import 'package:we_source_you/view/jobs/post_job/post_job_view/post_job_view.dart';
import 'package:we_source_you/view/kyc/view/kyc_view.dart';
import 'package:we_source_you/view/media_market/binding/media_binding.dart';
import 'package:we_source_you/view/media_market/media_market_view/media_market_view.dart';
import 'package:we_source_you/view/profile/profile_view/profile_view.dart';
import 'package:we_source_you/view/team/team_view/team_view.dart';

import '../view/inbox/inbox_page.dart';
import '../view/my_library/my_library_view.dart';
import '../view/pay/payout_settings_bindings.dart';
import '../view/pay/payout_settings_page.dart';
import '../widgets/payment_success.dart';

final appPages = <GetPage>[
  GetPage(name: AppRoutes.home, page: () => HomeView()),
  GetPage(
    name: AppRoutes.signin,
    page: () => SignInView(),
    binding: AuthBinding(),
  ),
  GetPage(name: AppRoutes.signup, page: () => SignUpView()),
  GetPage(name: AppRoutes.jobs, page: () => JobView()),
  GetPage(
    name: AppRoutes.media,
    page: () => MediaView(),
    binding: MediaBinding(),
  ),

  GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
  GetPage(name: AppRoutes.post, page: () => JobPostScreen()),
  GetPage(name: AppRoutes.applyJob, page: () => JobApply()),
  GetPage(name: AppRoutes.team, page: () => TeamView()),
  GetPage(name: AppRoutes.kyc, page: () => KycView()),
  GetPage(
    name: AppRoutes.adminDashboard,
    page: () => AdminDashboard(),
    middlewares: [AdminMiddleware()],
  ),
  GetPage(name: AppRoutes.myLibrary, page: () => MyLibraryPage()),
  GetPage(name: AppRoutes.inbox, page: () => InboxPage()),

  GetPage(name: '/payment-success', page: () => const PaymentSuccessPage()),
  GetPage(
    name: AppRoutes.payoutSettings,
    page: () => const PayoutSettingsPage(),
    binding: PayoutBinding(),
  ),
];
