import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TranslationService extends Translations {
  static Map<String, String>? en;
  static Map<String, String>? ar;

  static Future<void> init() async {
    final enString = await rootBundle.loadString("assets/languages/en.json");
    final arString = await rootBundle.loadString("assets/languages/ar.json");

    en = Map<String, String>.from(json.decode(enString));
    ar = Map<String, String>.from(json.decode(arString));
  }

  @override
  Map<String, Map<String, String>> get keys => {'en': en ?? {}, 'ar': ar ?? {}};
}
