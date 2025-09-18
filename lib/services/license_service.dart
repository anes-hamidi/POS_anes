import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/auth_service.dart';

class LicenseServices {
  static const String _licenseKey = "licenseKey";
  static const String _trialStartDateKey = "trialStartDate";
  static const int trialDays = 7;

  final _licenses = FirebaseFirestore.instance.collection("licenses");
  final _freeTrial = FirebaseFirestore.instance
      .collection("licenses")
      .doc("free_trial")
      .collection("keys");

  /// Save license locally
  Future<void> saveLicenseLocally(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, key);
  }

  Future<String?> getSavedLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }

  Future<void> clearLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
  }

  /// Start local trial if not already started
  Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_trialStartDateKey)) {
      await prefs.setString(
        _trialStartDateKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// 🔹 Centralized trial fallback (local only)
  Future<int> _getLocalTrialDays() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateStr = prefs.getString(_trialStartDateKey);

    if (startDateStr == null) return trialDays;

    final startDate = DateTime.tryParse(startDateStr) ?? DateTime.now();
    final daysUsed = DateTime.now().difference(startDate).inDays;

    return (trialDays - daysUsed).clamp(0, trialDays);
  }

  /// 🔹 Try Firebase → fallback to local
  Future<int> getTrialRemainingDays() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return _getLocalTrialDays();
    }

    try {
      final license = await getLicenseByUserId(userId);
      if (license != null && license["createdAt"] != null) {
final createdAt = license["createdAt"];
final startDate = createdAt is Timestamp
    ? createdAt.toDate()
    : DateTime.tryParse(createdAt?.toString() ?? "");
        final daysUsed = DateTime.now().difference(startDate!).inDays;
        return (trialDays - daysUsed).clamp(0, trialDays);
      }
    } catch (e) {
      print("⚠️ Error fetching trial/license from Firebase: $e");
    }

    // Fallback
    return _getLocalTrialDays();
  }

  Future<bool> isTrialExpired() async {
    return (await getTrialRemainingDays()) <= 0;
  }

  /// Validate license by key
  Future<bool> validateLicense(String key) async {
  try {
    final snapshot = await _licenses.doc(key).get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() ?? {};
    final expiry = data["expiryDate"];
    final expiryDate = expiry is Timestamp
        ? expiry.toDate()
        : DateTime.tryParse(expiry?.toString() ?? "");

    final isExpired = expiryDate != null && DateTime.now().isAfter(expiryDate);
    return data["isActive"] == true && !isExpired;
  } catch (_) {
    return false;
  }
}


  /// 🔹 Get license or trial info by userId
  Future<Map<String, dynamic>?> getLicenseByUserId(String userId) async {
    try {
      final query = await _licenses.where("userId", isEqualTo: userId).limit(1).get();
      final trialQuery = await _freeTrial.where("userId", isEqualTo: userId).limit(1).get();

      if (query.docs.isEmpty && trialQuery.docs.isEmpty) return null;

      final licenseDoc = query.docs.isNotEmpty ? query.docs.first : null;
      final trialDoc = trialQuery.docs.isNotEmpty ? trialQuery.docs.first : null;

      return {
        if (trialDoc != null) ...trialDoc.data(),
        if (licenseDoc != null) ...licenseDoc.data(),
        "id": trialDoc?.id ?? licenseDoc?.id,
      };
    } catch (e) {
      print("⚠️ getLicenseByUserId error: $e");
      return null;
    }
  }

  /// Check overall access (license OR trial)
  Future<bool> hasAccess() async {
    final localLicense = await getSavedLicense();
    if (localLicense != null && await validateLicense(localLicense)) {
      return true;
    }
    return !(await isTrialExpired());
  }
}
