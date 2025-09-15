
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LicenseService {
  static const String _licenseKey = 'licenseKey';
  static const String _trialStartDateKey = 'trialStartDate';

  Future<bool> isLicenseValid() async {
    final prefs = await SharedPreferences.getInstance();
    final licenseKey = prefs.getString(_licenseKey);
    return licenseKey != null;
  }

  Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartDateMillis = prefs.getInt(_trialStartDateKey);
    if (trialStartDateMillis == null) {
      return false;
    }
    final trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStartDateMillis);
    final trialEndDate = trialStartDate.add(const Duration(days: 7));
    return DateTime.now().isBefore(trialEndDate);
  }

  Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trialStartDateKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> activateLicense(String key) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('licenses').doc(key).get();
      if (doc.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licenseKey, key);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
