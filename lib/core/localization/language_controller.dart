import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final GetStorage _storage = GetStorage();
  
  // Observable variables
  final RxString currentLanguage = 'id'.obs;
  final RxString currentCurrency = 'IDR'.obs;
  final Rx<Locale> currentLocale = const Locale('id', 'ID').obs;
  
  // Supported languages
  final Map<String, Map<String, String>> supportedLanguages = {
    'id': {
      'code': 'id',
      'country': 'ID',
      'name': 'Bahasa Indonesia',
      'flag': '🇮🇩',
    },
    'en': {
      'code': 'en',
      'country': 'US',
      'name': 'English',
      'flag': '🇺🇸',
    },
  };
  
  // Supported currencies
  final Map<String, Map<String, String>> supportedCurrencies = {
    'IDR': {
      'code': 'IDR',
      'symbol': 'Rp',
      'name': 'Indonesian Rupiah',
      'locale': 'id_ID',
    },
    'USD': {
      'code': 'USD',
      'symbol': '\$',
      'name': 'US Dollar',
      'locale': 'en_US',
    },
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    // Load saved language
    final savedLanguage = _storage.read('language') ?? 'id';
    final savedCurrency = _storage.read('currency') ?? 'IDR';
    
    currentLanguage.value = savedLanguage;
    currentCurrency.value = savedCurrency;
    
    // Set locale based on language
    _updateLocale(savedLanguage);
  }

  void _updateLocale(String languageCode) {
    final language = supportedLanguages[languageCode];
    if (language != null) {
      currentLocale.value = Locale(language['code']!, language['country']!);
      Get.updateLocale(currentLocale.value);
    }
  }

  void changeLanguage(String languageCode) {
    if (supportedLanguages.containsKey(languageCode)) {
      currentLanguage.value = languageCode;
      _updateLocale(languageCode);
      _storage.write('language', languageCode);
      
      Get.snackbar(
        'Language Changed',
        'Language changed to ${supportedLanguages[languageCode]!['name']}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    }
  }

  void changeCurrency(String currencyCode) {
    if (supportedCurrencies.containsKey(currencyCode)) {
      currentCurrency.value = currencyCode;
      _storage.write('currency', currencyCode);
      
      Get.snackbar(
        'Currency Changed',
        'Currency changed to ${supportedCurrencies[currencyCode]!['name']}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    }
  }

  // Format currency based on current currency setting
  String formatCurrency(double amount) {
    final currency = supportedCurrencies[currentCurrency.value]!;
    final symbol = currency['symbol']!;
    
    if (currentCurrency.value == 'IDR') {
      // Indonesian Rupiah formatting with proper Indonesian terms
      if (amount >= 1000000000) {
        // Miliar (Billion)
        return '$symbol ${(amount / 1000000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000000) {
        // Juta (Million)
        return '$symbol ${(amount / 1000000).toStringAsFixed(1)}jt';
      } else if (amount >= 1000) {
        // Ribu (Thousand)
        return '$symbol ${(amount / 1000).toStringAsFixed(0)}rb';
      } else {
        return '$symbol ${amount.toStringAsFixed(0)}';
      }
    } else {
      // USD formatting
      if (amount >= 1000000000) {
        return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      } else {
        return '$symbol${amount.toStringAsFixed(2)}';
      }
    }
  }

  // Format number based on current locale
  String formatNumber(double number) {
    if (currentLanguage.value == 'id') {
      // Indonesian number formatting
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } else {
      // English number formatting
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
  }

  // Get current language name
  String get currentLanguageName {
    return supportedLanguages[currentLanguage.value]!['name']!;
  }

  // Get current currency name
  String get currentCurrencyName {
    return supportedCurrencies[currentCurrency.value]!['name']!;
  }

  // Get current currency symbol
  String get currentCurrencySymbol {
    return supportedCurrencies[currentCurrency.value]!['symbol']!;
  }

  // Check if current language is Indonesian
  bool get isIndonesian => currentLanguage.value == 'id';

  // Check if current language is English
  bool get isEnglish => currentLanguage.value == 'en';

  // Check if current currency is IDR
  bool get isIDR => currentCurrency.value == 'IDR';

  // Check if current currency is USD
  bool get isUSD => currentCurrency.value == 'USD';
}
