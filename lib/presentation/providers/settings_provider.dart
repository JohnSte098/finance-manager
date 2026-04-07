// lib/presentation/providers/settings_provider.dart
import 'package:flutter/material.dart';
import '../../data/datasources/hive_db.dart';

class SettingsProvider extends ChangeNotifier {
  static const _currencyKey = 'currency';
  static const _biometricKey = 'biometric';
  static const _userNameKey = 'userName';

  String get currency => HiveDb.settings.get(_currencyKey, defaultValue: 'USD') as String;
  bool   get biometricEnabled => HiveDb.settings.get(_biometricKey, defaultValue: false) as bool;
  String get userName => HiveDb.settings.get(_userNameKey, defaultValue: 'User') as String;

  Future<void> setCurrency(String code) async {
    await HiveDb.settings.put(_currencyKey, code);
    notifyListeners();
  }

  Future<void> setBiometric(bool enabled) async {
    await HiveDb.settings.put(_biometricKey, enabled);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await HiveDb.settings.put(_userNameKey, name);
    notifyListeners();
  }
}
