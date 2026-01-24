import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:we_source_you/binding/app_binding.dart';
import 'package:we_source_you/core/constant/app_theme.dart';
import 'package:we_source_you/core/services/translation_service.dart';
import 'package:we_source_you/firebase_options.dart';
import 'package:we_source_you/routes/app_pages.dart';
import 'package:we_source_you/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services with proper error handling
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Initializing GetStorage...');
    await GetStorage.init();

    debugPrint('Initializing TranslationService...');
    await TranslationService.init();

    Stripe.publishableKey =
        'pk_test_51SpwZTCQW8mXVTllBaVKzHUihCZtfYeEoptVYBArjicVUDWeG8AoCbX8eGLaFgD4qm8NOYoOxlgqCRpCPGPJlGTr00wsUO8qhL';

    debugPrint('All services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue anyway - the app might still work with partial initialization
  }

  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      ensureScreenSize: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: TranslationService(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(context),
          darkTheme: AppTheme.dark(context),
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.home,
          initialBinding: AppBinding(),
          getPages: appPages,
          key: UniqueKey(),
        );
      },
    );
  }
}
