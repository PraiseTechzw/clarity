import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _languageKey = 'language';
  static const String _currencyKey = 'currency';

  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  String get selectedLanguage => _selectedLanguage;
  String get selectedCurrency => _selectedCurrency;

  LocaleProvider() {
    _loadLocaleSettings();
  }

  Future<void> _loadLocaleSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(_languageKey) ?? 'English';
    _selectedCurrency = prefs.getString(_currencyKey) ?? 'USD';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _selectedCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  String getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'ZWL':
        return 'Z\$';
      default:
        return '\$';
    }
  }

  List<String> getSupportedLanguages() {
    return [
      'English',
      'Spanish',
      'French',
      'German',
      'Portuguese',
      'Italian',
      'Chinese',
      'Japanese',
      'Korean',
      'Arabic',
    ];
  }

  List<String> getSupportedCurrencies() {
    return ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'ZWL'];
  }

  String getCurrencyDisplayName(String currency) {
    switch (currency) {
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      case 'GBP':
        return 'British Pound (£)';
      case 'JPY':
        return 'Japanese Yen (¥)';
      case 'CAD':
        return 'Canadian Dollar (C\$)';
      case 'AUD':
        return 'Australian Dollar (A\$)';
      case 'ZWL':
        return 'Zimbabwean Dollar (Z\$)';
      default:
        return 'US Dollar (\$)';
    }
  }
}
