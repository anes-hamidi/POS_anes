// settingsProvider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool allowSaleWithoutStock = false;
  

  String businessName = "";
  String businessPhone = "";
  String businessEmail = "";
  String businessAddress = "";

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    allowSaleWithoutStock = prefs.getBool('allowSaleWithoutStock') ?? false;


    businessName = prefs.getString('businessName') ?? "";
    businessPhone = prefs.getString('businessPhone') ?? "";
    businessEmail = prefs.getString('businessEmail') ?? "";
    businessAddress = prefs.getString('businessAddress') ?? "";

    notifyListeners();
  }

  Future<void> toggleAllowSaleWithoutStock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    allowSaleWithoutStock = value;
    await prefs.setBool('allowSaleWithoutStock', value);
    notifyListeners();
  }

  Future<void> updateBusinessInfo({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    businessName = name;
    businessPhone = phone;
    businessEmail = email;
    businessAddress = address;

    await prefs.setString('businessName', name);
    await prefs.setString('businessPhone', phone);
    await prefs.setString('businessEmail', email);
    await prefs.setString('businessAddress', address);

    notifyListeners();
  }
}
