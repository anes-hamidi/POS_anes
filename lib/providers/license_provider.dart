import 'package:flutter/material.dart';
import 'package:myapp/services/license_service.dart';
import 'package:myapp/models/license.dart';

class LicenseProvider extends ChangeNotifier {
  final LicenseServices _service = LicenseServices();

  String? _licenseKey;
  bool _isValid = false;
  int _trialDaysRemaining = 0;
  String? _userId;
  License? _license;

  // 🔹 Getters
  String? get licenseKey => _licenseKey;
  bool get isValid => _isValid;
  int get trialDaysRemaining => _trialDaysRemaining;
  String? get userId => _userId;
  License? get license => _license;

  /// Remaining trial days & status
  int get remainingTrialDays => _trialDaysRemaining;
  bool get isTrialActive => _trialDaysRemaining > 0 && !_isValid;

  LicenseProvider() {
    _init();
  }

  /// ✅ Initialization with optional userId
  Future<void> initialize(String userId) async {
    _userId = userId;
    await _init();
  }

  /// 🔹 Internal initialization
  Future<void> _init() async {
    // Load saved license
    _licenseKey = await _service.getSavedLicense();

    if (_licenseKey != null) {
      _isValid = await _service.validateLicense(_licenseKey!);
    }

    // If userId is provided → fetch license from Firestore
    if (_userId != null) {
      final licenseData = await _service.getLicenseByUserId(_userId!);
      if (licenseData != null) {
        _license = License.fromJson(licenseData, licenseData['id']);
        _licenseKey ??= _license?.id; // Sync key if not saved locally
        _isValid = _license?.isActive ?? false;
      }
    }

    // Handle trial
    await _service.startTrial();
    _trialDaysRemaining = await _service.getTrialRemainingDays();

    notifyListeners();
  }

  /// ✅ Activate license manually
  Future<bool> activateLicense(String key) async {
    final isValid = await _service.validateLicense(key);
    if (isValid) {
      await _service.saveLicenseLocally(key);
      _licenseKey = key;
      _isValid = true;

      // Sync license from Firestore if userId available
      if (_userId != null) {
        final licenseData = await _service.getLicenseByUserId(_userId!);
        if (licenseData != null) {
          _license = License.fromJson(licenseData, licenseData['id']);
        }
      }
    } else {
      _isValid = false;
    }

    notifyListeners();
    return _isValid;
  }

  /// ✅ Clear license
  Future<void> clearLicense() async {
    await _service.clearLicense();
    _licenseKey = null;
    _isValid = false;
    _license = null;
    notifyListeners();
  }

  /// ✅ Start trial
  Future<void> startTrial() async {
    await _service.startTrial();
    _trialDaysRemaining = await _service.getTrialRemainingDays();
    notifyListeners();
  }
}
