import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/providers/themeProvider.dart';
import 'package:myapp/screens/license_screen.dart';
import 'package:myapp/screens/payment_screen.dart';
import 'package:myapp/screens/settings.dart';
import 'package:myapp/screens/subscription_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/license_provider.dart';
import './pos_screen.dart';
import './product_screen.dart';
import './customer_screen.dart';
import './invoice_history_screen.dart';
import '../widgets/common/themed_scaffold.dart';
import '../widgets/dashboard/dashboard_item.dart';

 import 'package:myapp/data/database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;
  late AppDatabase _db;

  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';

  int _totalProducts = 0;
  int _totalCustomers = 0;
  int _todaySales = 0;

  @override
  void initState() {
    super.initState();
    _db = Provider.of<AppDatabase>(context, listen: false);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _updateDateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDateTime(),
    );

    _loadDashboardData();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final productCount = await _db.products.select().get();
      final customerCount = await _db.customers.select().get();
      final today = DateTime.now();

      final invoiceCount =
          await (_db.select(_db.sales)
                ..where(
                  (tbl) => tbl.saleDate.isBiggerOrEqualValue(
                    DateTime(today.year, today.month, today.day),
                  ),
                )
                ..where(
                  (tbl) => tbl.saleDate.isSmallerThanValue(
                    DateTime(today.year, today.month, today.day + 1),
                  ),
                ))
              .get();

      setState(() {
        _totalProducts = productCount.length;
        _totalCustomers = customerCount.length;
        _todaySales = invoiceCount.length;
      });
    } catch (e, stack) {
      debugPrint("Error loading dashboard data: $e\n$stack");
    }
  }
   getUserName(userId) async {
    final userName = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => doc['name'] as String? ?? 'User');
          return userName.toString();

  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }
   
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final licenseProvider = Provider.of<LicenseProvider>(context);
    final t = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> dashboardItems = [
      {
        'icon': Icons.point_of_sale,
        'label': t.pos,
        'screen': const POSScreen(),
      },
      {
        'icon': Icons.inventory_2,
        'label': t.products,
        'screen': const ProductScreen(),
      },
      {
        'icon': Icons.people,
        'label': t.customers,
        'screen': const CustomerScreen(),
      },
      {
        'icon': Icons.receipt_long,
        'label': t.invoice,
        'screen': const InvoiceHistoryScreen(),
      },
      {
        'icon': Icons.settings,
        'label': t.settings,
        'screen': const SettingsScreen(),
      },
      {
        'icon': Icons.payment,
        'label': t.payments,
        'screen': const PaymentsScreen(),
      }
    ];

    _animations = List.generate(
      dashboardItems.length,
      (index) => Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
        ),
      ),
    );
    _animationController.forward();

    return ThemedScaffold(
      appBar: AppBar(
        title: Text(t.dashboard),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: t.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LicenseScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.subscriptions),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubscriptionScreenA(),
                ),
              );
            },
          ),
          
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🕒 Date & Time
              Center(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentDate,
                        key: ValueKey(_currentDate),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentTime,
                        key: ValueKey(_currentTime),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 📊 Summary Row
              Row(
                children: [
                  _buildSummaryCard(
                    t.products,
                    _totalProducts.toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    t.customers,
                    _totalCustomers.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildSummaryCard(
                    t.sales,
                    _todaySales.toString(),
                    Icons.point_of_sale,
                    Colors.purple,
                  ),

                ],
              ),

              const SizedBox(height: 30),

              // 🔲 Dashboard Items
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  return ScaleTransition(
                    scale: _animations[index],
                    child: Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  dashboardItems[index]['screen'],
                            ),
                          );
                        },
                        child: DashboardItem(
                          icon: dashboardItems[index]['icon'],
                          label: dashboardItems[index]['label'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    dashboardItems[index]['screen'],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 13, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
