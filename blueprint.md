
# Blueprint

## Overview

This document outlines the plan for implementing a license-based access control system with a 7-day free trial for the application.

## Current Plan

### 1. Create `lib/services/license_service.dart`

This service will manage license validation and free trial logic.

- **`isLicenseValid()`**: Checks if the license is active.
- **`isTrialActive()`**: Checks if the free trial is active.
- **`startTrial()`**: Starts the 7-day free trial.
- **`activateLicense(String key)`**: Activates a license key.

### 2. Create `lib/screens/license_screen.dart`

This screen will be shown when the license is invalid or the trial has expired. It will contain:

- A text field for the license key.
- An "Activate" button.
- An upgrade message.

### 3. Modify `lib/main.dart`

- At startup, the app will check the license status and navigate to the appropriate screen (`DashboardScreen` or `LicenseScreen`).

### 4. Create `lib/models/license.dart`

- A data model for the license, including the key and expiration date.

### 5. Integrate Firebase

- Add `cloud_firestore` and `firebase_core` to `pubspec.yaml`.
- Use Firestore to validate license keys from a "licenses" collection.

### 6. Update `pubspec.yaml`

- Add the required dependencies.
