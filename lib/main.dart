import 'package:flutter/material.dart';
import 'package:myapp/providers/PrinterProvide.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data/database.dart';
import 'providers/cart_provider.dart';
import 'services/pdf_service.dart';
import 'services/printer_service.dart';
import 'services/qr_service.dart';
import 'services/barcode_service.dart';
import 'services/image_picker_service.dart';
import 'services/confirmation_dialog_service.dart';
import 'services/sale_service.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ REQUIRED before SharedPreferences

  runApp(

 MultiProvider(
  providers: [
    Provider<AppDatabase>(create: (_) => AppDatabase()),
    ChangeNotifierProvider(create: (context) => CartProvider(context.read<AppDatabase>())),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    Provider(create: (_) => PdfService()),
    Provider(create: (_) => PrinterService()),
    ChangeNotifierProvider(
      create: (context) => PrinterProvider(printerService: context.read<PrinterService>()),
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
        return SaleService(db: db, pdfService: pdfService, printerService: printerService);
      },
    ),
   

  ],
  child: const MyApp(),
)

  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color.fromARGB(255, 12, 181, 147);

    final TextTheme appTextTheme = TextTheme(
      
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'roboto'),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: 'roboto'),
      bodyMedium: TextStyle(fontSize: 14, fontFamily: 'roboto'),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'roboto'),
      bodySmall: TextStyle(fontSize: 12, fontFamily: 'roboto'),
    );

    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    // --- Light Theme --- //
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
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
        ),
      ),
      inputDecorationTheme: inputDecorationTheme,
    );

    // --- Dark Theme --- //
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        background: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'roboto'),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
       elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'roboto'),
        ),
      ),
      inputDecorationTheme: inputDecorationTheme,
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Inventory & POS Pro',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
