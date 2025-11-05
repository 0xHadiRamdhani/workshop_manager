import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workshop_screen.dart';
import 'screens/cashier_screen.dart';
import 'models/vehicle.dart';
import 'models/transaction.dart';
import 'database/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );

  // Initialize database and check path
  _initializeDatabase();

  runApp(const WorkshopManagerApp());
}

Future<void> _initializeDatabase() async {
  try {
    print('Main: Initializing database...');
    final dbHelper = DatabaseHelper.instance;

    // Check database path
    final dbPath = await dbHelper.getDatabasePath();
    print('Main: Database path: $dbPath');

    // Test database connection
    final isConnected = await dbHelper.isDatabaseOpen();
    print('Main: Database connection status: $isConnected');

    // Get initial data count for debugging
    final products = await dbHelper.getProducts();
    print('Main: Initial products count: ${products.length}');

    final vehicles = await dbHelper.getVehicles();
    print('Main: Initial vehicles count: ${vehicles.length}');

    final transactions = await dbHelper.getTransactions();
    print('Main: Initial transactions count: ${transactions.length}');
  } catch (e) {
    print('Main: Error initializing database: $e');
  }
}

class WorkshopManagerApp extends StatefulWidget {
  const WorkshopManagerApp({super.key});

  @override
  State<WorkshopManagerApp> createState() => _WorkshopManagerAppState();
}

class _WorkshopManagerAppState extends State<WorkshopManagerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed: $state');

    if (state == AppLifecycleState.paused) {
      // App is going to background
      print('App going to background - closing database...');
      _closeDatabase();
    } else if (state == AppLifecycleState.resumed) {
      // App is coming to foreground
      print('App coming to foreground - database will be reinitialized');
    }
  }

  Future<void> _closeDatabase() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.close();
      print('Database closed successfully');
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Workshop Manager',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.black,
        barBackgroundColor: CupertinoColors.darkBackgroundGray,
        textTheme: CupertinoTextThemeData(primaryColor: CupertinoColors.white),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkshopScreen(),
    const CashierScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: 25),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wrench, size: 25),
            label: 'Workshop',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar, size: 25),
            label: 'Kasir',
          ),
        ],
        activeColor: CupertinoColors.systemBlue,
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: CupertinoColors.darkBackgroundGray.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            // Refresh DashboardScreen saat tab-nya aktif
            if (index == 0 && _currentIndex != index) {
              _currentIndex = index;
              // Delay sedikit untuk memastikan screen sudah siap
              Future.delayed(const Duration(milliseconds: 100), () {
                // Coba refresh DashboardScreen jika tersedia
                print('Main: Dashboard tab activated, refreshing...');
              });
            } else if (index != 0) {
              _currentIndex = index;
            }
            return _screens[index];
          },
        );
      },
    );
  }
}
