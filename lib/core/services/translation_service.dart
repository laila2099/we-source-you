import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class TranslationService extends Translations {
  static Map<String, String>? en;
  static Map<String, String>? ar;
  static bool _isInitialized = false;

  static Future<void> init() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      debugPrint('TranslationService already initialized');
      return;
    }

    try {
      debugPrint('Initializing TranslationService...');
      
      // Load translation files with error handling
      final enString = await rootBundle.loadString("assets/languages/en.json");
      final arString = await rootBundle.loadString("assets/languages/ar.json");

      en = Map<String, String>.from(json.decode(enString));
      ar = Map<String, String>.from(json.decode(arString));
      
      _isInitialized = true;
      debugPrint('TranslationService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing TranslationService: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Set empty maps as fallback to prevent null errors
      en = {};
      ar = {};
      
      // Re-throw to let the caller handle it if needed
      // But don't mark as initialized so it can be retried
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {'en': en ?? {}, 'ar': ar ?? {}};
}
