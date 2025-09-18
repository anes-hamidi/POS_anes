import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:myapp/providers/license_provider.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:myapp/providers/settingProvider.dart';
import 'package:myapp/providers/themeProvider.dart';
import 'package:myapp/screens/BusinessInfoScreen.dart';
import 'package:myapp/screens/subscription_screen.dart';
import 'package:myapp/services/googleDriveService.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _showPrinterSelector(BuildContext context) async {
    final printerProvider = Provider.of<PrinterProvider>(
      context,
      listen: false,
    );

    try {
      final devices = await printerProvider.getBondedDevices();

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.selectPrinter),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(
                      device.name ?? AppLocalizations.of(context)!.unknownDevice,
                    ),
                    subtitle: Text(device.address ?? ""),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await printerProvider.connectTo(device);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!
                                    .connectedToPrinter(device.name ?? ''),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!
                                    .connectionFailed(e.toString()),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToGetPrinters(e.toString()),
            ),
          ),
        );
      }
    }
  }
 @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final printerProvider = Provider.of<PrinterProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<LicenseProvider> (
      builder: (context, licenseProvider, _)  {
        // 🔑 Status & expiry
        final license = licenseProvider.license;
        final isLicensed = licenseProvider.isValid;
        final isTrial = licenseProvider.isTrialActive;
        final trialDaysLeft = licenseProvider.remainingTrialDays;
        final expiryDate = license?.expiryDate;
        final userId = FirebaseAuth.instance.currentUser?.uid;
        final userName = FirebaseAuth.instance.currentUser?.email ?? 'Guest';
        final bool isLocked = !isLicensed && !isTrial;

        String subscriptionStatus;
        if (isLicensed && license != null) {
          subscriptionStatus = "Licensed (${license.type})";
        } else if (isTrial) {
          subscriptionStatus = "Free Trial (Active)";
        } else {
          subscriptionStatus = "No valid subscription";
        }

        // 🔢 Trial progress calculation
        double trialProgress =
            trialDaysLeft > 0 ? (7 - trialDaysLeft) / 7 : 1;

        // 🔌 Printer connection status
        String statusText;
        switch (printerProvider.state) {
          case PrinterConnectionState.connecting:
            statusText = AppLocalizations.of(context)!.connecting;
            break;
          case PrinterConnectionState.connected:
            statusText = AppLocalizations.of(context)!
                .connectedToPrinter(printerProvider.connectedDevice?.name ?? '');
            break;
          case PrinterConnectionState.disconnected:
          default:
            statusText = AppLocalizations.of(context)!.disconnected;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // TODO: Implement logout functionality
                  Navigator.of(context).pushReplacementNamed('/subscription');
                },
              ),
            ],
          ),
          
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Subscription Card
             // Subscription Card
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: isLicensed
      ? Colors.green.shade200
      : isTrial
          ? Colors.orange.shade200
          : Colors.red.shade200,
  child: Column(
    children: [
      ListTile(
        leading: const Icon(Icons.subscriptions),
        title: const Text("Subscription"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subscriptionStatus),
            Text("User: ${FirebaseAuth.instance.currentUser?.displayName ?? userName}"),
          ],
        ),
      ),

      // Expiry date for licensed users
      if (expiryDate != null)
        ListTile(
          leading: const Icon(Icons.event),
          title: const Text("Expiry Date"),
          subtitle: Text(
            expiryDate.isBefore(DateTime.now())
                ? "Expired on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}"
                : "${expiryDate.day}/${expiryDate.month}/${expiryDate.year} "
                  "(${expiryDate.difference(DateTime.now()).inDays} days left)",
          ),
        ),

      // Trial progress
      if (isTrial)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: trialProgress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 6),
              Text(
                trialDaysLeft > 0
                    ? "$trialDaysLeft days left of free trial"
                    : "Trial expired",
              ),
            ],
          ),
        ),

      // Subscribe button
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.payment),
          label: Text(isLicensed ? "Renew Subscription" : "Subscribe"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreenA()),
            );
          },
        ),
      ),
    ],
  ),
),


              const SizedBox(height: 12),

              // Business Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.businessInformation,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text(AppLocalizations.of(context)!.manageStoreDetails),
                      leading: const Icon(Icons.store),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title:
                          Text(AppLocalizations.of(context)!.editBusinessInfo),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BusinessInfoScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Printer Settings (Locked if expired/unlicensed)
              LockOverlay(
                locked: isLocked,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.printerSettings,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(AppLocalizations.of(context)!
                            .connectAndManagePrinters),
                        leading: const Icon(Icons.print),
                      ),
                      ListTile(
                        leading: const Icon(Icons.print_outlined),
                        title: Text(
                          AppLocalizations.of(context)!.printerConnection,
                        ),
                        subtitle: Text(statusText),
                        trailing: printerProvider.isConnected
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await printerProvider.disconnect();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .disconnected,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )
                            : null,
                        onTap: () => _showPrinterSelector(context),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Database Backup & Restore (Locked)
              LockOverlay(
                locked: isLocked,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cloud_upload),
                        title: Text(
                            AppLocalizations.of(context)!.backupToGoogleDrive),
                        onTap: () async {
                          if (isLocked) return;
                          try {
                            final backupZipPath = p.join(
                              (await getTemporaryDirectory()).path,
                              'db_backup.zip',
                            );

                            final file = await db.backupDatabaseAsZip(
                              backupZipPath,
                            );
                            await GoogleDriveService().uploadBackup(file);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.backupSuccess,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .backupFailed(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.cloud_download),
                        title: Text(AppLocalizations.of(context)!
                            .restoreFromGoogleDrive),
                        onTap: () async {
                          if (isLocked) return;
                          try {
                            final savePath = p.join(
                              (await getTemporaryDirectory()).path,
                              'db_restore.zip',
                            );

                            final file = await GoogleDriveService()
                                .downloadBackup(savePath);
                            if (file == null) {
                              throw Exception("No backup found");
                            }

                            await db.restoreDatabaseFromZip(file.path);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .restoreSuccess,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .restoreFailed(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // General Settings
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        return LockOverlay(
                          locked: isLocked,
                          child: SwitchListTile(
                            title: Text(
                              AppLocalizations.of(context)!
                                  .allowSaleWithoutStock,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context)!
                                  .allowSaleWithoutStockDesc,
                            ),
                            value: settings.allowSaleWithoutStock,
                            onChanged: isLocked
                                ? null
                                : (val) {
                                    settings.toggleAllowSaleWithoutStock(val);
                                  },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.appSettings,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          AppLocalizations.of(context)!.appSettingsSubtitle),
                      leading: const Icon(Icons.settings),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      title: Text(
                        themeProvider.themeMode == ThemeMode.dark
                            ? AppLocalizations.of(context)!.lightMode
                            : AppLocalizations.of(context)!.darkMode,
                      ),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(AppLocalizations.of(context)!.language),
                      subtitle: Text(
                          AppLocalizations.of(context)!.changeAppLanguage),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String selectedLanguage =
                                Localizations.localeOf(context).languageCode;
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter setState) {
                                return AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .selectLanguage,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RadioListTile(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .english),
                                        value: 'en',
                                        groupValue: selectedLanguage,
                                        onChanged: (value) {
                                          setState(
                                              () => selectedLanguage = value!);
                                        },
                                      ),
                                      RadioListTile(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .arabic),
                                        value: 'ar',
                                        groupValue: selectedLanguage,
                                        onChanged: (value) {
                                          setState(
                                              () => selectedLanguage = value!);
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                          AppLocalizations.of(context)!.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final localeProvider =
                                            Provider.of<LocaleProvider>(
                                                context,
                                                listen: false);
                                        localeProvider.setLocale(
                                          Locale(selectedLanguage),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.apply),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🔒 Lock Overlay Widget
class LockOverlay extends StatelessWidget {
  final Widget child;
  final bool locked;

  const LockOverlay({super.key, required this.child, required this.locked});

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: AbsorbPointer(child: child),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 40, color: Colors.redAccent),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text("Subscribe to unlock"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionScreenA()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
