import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:we_source_you/binding/app_binding.dart';
import 'package:we_source_you/core/constant/app_theme.dart';
import 'package:we_source_you/core/services/translation_service.dart';
import 'package:we_source_you/firebase_options.dart';
import 'package:we_source_you/routes/app_pages.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
  await TranslationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
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
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.home,
          initialBinding: AppBinding(),
          getPages: appPages,
        );
      },
    );
  }
}
