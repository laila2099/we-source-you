import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();

    if (auth.role.value != 'admin') {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
