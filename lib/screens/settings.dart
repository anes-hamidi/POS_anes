import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:myapp/providers/settingProvider.dart';
import 'package:myapp/providers/themeProvider.dart';
import 'package:myapp/screens/BusinessInfoScreen.dart';
import 'package:myapp/services/googleDriveService.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showPrinterSelector(BuildContext context) async {
    final printerProvider = Provider.of<PrinterProvider>(
      context,
      listen: false,
    );

    try {
      final devices = await printerProvider.getBondedDevices();

      // Show list of bonded printers
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
                    title: Text(device.name ?? AppLocalizations.of(context)!.unknownDevice),
                    subtitle: Text(device.address ?? ""),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await printerProvider.connectTo(device);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.connectedToPrinter(device.name ?? '')),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.connectionFailed(e.toString()))),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToGetPrinters(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final printerProvider = Provider.of<PrinterProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);


    String statusText;
    switch (printerProvider.state) {
      case PrinterConnectionState.connecting:
        statusText = AppLocalizations.of(context)!.connecting;
        break;
      case PrinterConnectionState.connected:
        statusText = AppLocalizations.of(context)!.connectedToPrinter(printerProvider.connectedDevice?.name ?? '');
        break;
      case PrinterConnectionState.disconnected:
      default:
        statusText = AppLocalizations.of(context)!.disconnected;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.manageStoreDetails,
                  ),
                  leading: Icon(Icons.store),
                ),
                ListTile(
  leading: const Icon(Icons.info_outline),
  title: Text(AppLocalizations.of(context)!.editBusinessInfo),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BusinessInfoScreen()),
    );
  },
),

              ],
            ),
          ),

          const SizedBox(height: 12),

          // Printer Settings with live connection state
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                 ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.printerSettings,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.connectAndManagePrinters),
                  leading: Icon(Icons.print),
                ),
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: Text(AppLocalizations.of(context)!.printerConnection),
                  subtitle: Text(statusText),
                  trailing: printerProvider.isConnected
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await printerProvider.disconnect();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.disconnected),
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
          const SizedBox(height: 12),

          // Database Backup & Restore
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
            ListTile(
  leading: const Icon(Icons.cloud_upload),
  title: Text(AppLocalizations.of(context)!.backupToGoogleDrive),
  onTap: () async {
    try {
      final backupZipPath = p.join(
        (await getTemporaryDirectory()).path,
        'db_backup.zip',
      );

      final file = await db.backupDatabaseAsZip(backupZipPath);
      await GoogleDriveService().uploadBackup(file);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.backupSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.backupFailed(e.toString()))),
        );
      }
    }
  },
),
ListTile(
  leading: const Icon(Icons.cloud_download),
  title: Text(AppLocalizations.of(context)!.restoreFromGoogleDrive),
  onTap: () async {
    try {
      final savePath = p.join(
        (await getTemporaryDirectory()).path,
        'db_restore.zip',
      );

      final file = await GoogleDriveService().downloadBackup(savePath);
      if (file == null) throw Exception("No backup found");

      await db.restoreDatabaseFromZip(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restoreSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restoreFailed(e.toString()))),
        );
      }
    }
  },
),
 ],
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
    return SwitchListTile(
      title: Text(AppLocalizations.of(context)!.allowSaleWithoutStock),
      subtitle: Text(AppLocalizations.of(context)!.allowSaleWithoutStockDesc),
      value: settings.allowSaleWithoutStock,
      onChanged: (val) {
        settings.toggleAllowSaleWithoutStock(val);
      },
    );
  },
),

                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.appSettings,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.appSettingsSubtitle),
                  leading: Icon(Icons.settings),
                ),
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  title: Text(themeProvider.themeMode == ThemeMode.dark
                      ? AppLocalizations.of(context)!.lightMode
                      : AppLocalizations.of(context)!.darkMode),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title:  Text(AppLocalizations.of(context)!.language),
                  subtitle:  Text(AppLocalizations.of(context)!.changeAppLanguage),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String selectedLanguage = Localizations.localeOf(
                          context,
                        ).languageCode;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.selectLanguage,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile(
                                    title: Text(AppLocalizations.of(context)!.english),
                                    value: 'en',
                                    groupValue: selectedLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value!;
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title:  Text(AppLocalizations.of(context)!.arabic),
                                    value: 'ar',
                                    groupValue: selectedLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Apply the selected language
                                    // You'll need to access the main app's state and update the locale
                                    // For example, using a provider or inherited widget
                                    // MyApp.of(context).setLocale(Locale(selectedLanguage));
                                  
                                      final localeProvider =
                                          Provider.of<LocaleProvider>(
                                            context,
                                            listen: false,
                                          );
                                      localeProvider.setLocale(
                                        Locale(selectedLanguage),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  
                                  child: Text(
                                    AppLocalizations.of(context)!.apply,
                                  ),
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
  }
}
