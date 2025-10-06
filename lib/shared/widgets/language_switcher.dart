import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/localization/language_controller.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();

    return Obx(() => PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageController.supportedLanguages[languageController.currentLanguage.value]!['flag']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              languageController.supportedLanguages[languageController.currentLanguage.value]!['code']!.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (String languageCode) {
        languageController.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return languageController.supportedLanguages.entries.map((entry) {
          final languageCode = entry.key;
          final languageData = entry.value;
          final isSelected = languageCode == languageController.currentLanguage.value;

          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              children: [
                Text(
                  languageData['flag']!,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageData['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Get.theme.primaryColor : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Get.theme.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
    ));
  }
}

class CurrencySwitcher extends StatelessWidget {
  const CurrencySwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();

    return Obx(() => PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageController.supportedCurrencies[languageController.currentCurrency.value]!['symbol']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              languageController.currentCurrency.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (String currencyCode) {
        languageController.changeCurrency(currencyCode);
      },
      itemBuilder: (BuildContext context) {
        return languageController.supportedCurrencies.entries.map((entry) {
          final currencyCode = entry.key;
          final currencyData = entry.value;
          final isSelected = currencyCode == languageController.currentCurrency.value;

          return PopupMenuItem<String>(
            value: currencyCode,
            child: Row(
              children: [
                Text(
                  currencyData['symbol']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currencyData['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Get.theme.primaryColor : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Get.theme.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList();
      },
    ));
  }
}
