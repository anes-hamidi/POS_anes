import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:myapp/providers/settingProvider.dart';
import 'package:myapp/providers/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// Import Firebase Firestore
import 'package:myapp/providers/license_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'providers/cart_provider.dart';
import 'services/pdf_service.dart';
import 'services/printer_service.dart';
import 'services/qr_service.dart';
import 'services/barcode_service.dart';
import 'services/image_picker_service.dart';
import 'services/confirmation_dialog_service.dart';
import 'services/sale_service.dart';
import 'providers/locale_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/license_service.dart';
import 'screens/subscription_stepper.dart'; // Import the Stepper widget
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  // get the current user id
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  // TODO: Replace with real authenticated userId
  const String defaultUserId = 'testUserId';
  final prefs = await SharedPreferences.getInstance();
  final sharedPrefUserId = prefs.getString('userId') ?? defaultUserId;

  final licenseProvider = LicenseProvider();
  await licenseProvider.initialize(sharedPrefUserId!);

  String initialRoute = '/subscription';
  if (FirebaseAuth.instance.currentUser != null) {
    initialRoute = '/dashboard';
  } else {
    initialRoute = '/subscription';
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(create: (_) => AppDatabase()),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => licenseProvider),
        ChangeNotifierProvider(
          create: (context) => CartProvider(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(create: (_) => themeProvider),
        Provider(create: (_) => PdfService()),
        Provider(create: (_) => PrinterService()),
        ChangeNotifierProvider(
          create: (context) =>
              PrinterProvider(printerService: context.read<PrinterService>()),
        ),
        Provider(create: (_) => QrService()),
        Provider(create: (_) => BarcodeService()),
        Provider(create: (_) => ImagePickerService()),
        Provider(create: (_) => ConfirmationDialogService()),
        Provider<SaleService>(
          create: (context) {
            final db = context.read<AppDatabase>();
            final pdfService = context.read<PdfService>();
            final printerService = context.read<PrinterService>();
            return SaleService(
              db: db,
              pdfService: pdfService,
              printerService: printerService,
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => localeProvider),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    const Color primarySeedColor = Color.fromARGB(255, 12, 181, 147);

    final TextTheme appTextTheme = TextTheme(
      displayLarge: const TextStyle(
          fontSize: 57, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      displayMedium: const TextStyle(
          fontSize: 45, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      displaySmall: const TextStyle(
          fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      headlineMedium: const TextStyle(
          fontSize: 34, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      headlineSmall: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      titleLarge: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'roboto'),
      titleSmall: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      bodyLarge: const TextStyle(fontSize: 16, fontFamily: 'roboto'),
      bodyMedium: const TextStyle(fontSize: 14, fontFamily: 'roboto'),
      labelLarge: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'roboto'),
      bodySmall: const TextStyle(fontSize: 12, fontFamily: 'roboto'),
    );

    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        background: const Color(0xFFF8F9FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(31, 0, 0, 0),
        elevation: 0,
        foregroundColor: primarySeedColor,
        titleTextStyle: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
        ),
      ),
      inputDecorationTheme: inputDecorationTheme,
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        background: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      textTheme: appTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
        ),
      ),
      inputDecorationTheme: inputDecorationTheme,
    );

    return MaterialApp(
      title: 'Inventory & POS Pro',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: widget.initialRoute,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Free Trial Subscription')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SubscriptionStepper(),
      ),
    );
  }
}
