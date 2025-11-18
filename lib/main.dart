import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workshop_manager/screens/about_school_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workshop_screen.dart';
import 'screens/cashier_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/about_screen.dart';
import 'screens/printer_settings_screen.dart';
import 'screens/technician_management_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/debt_management_screen.dart';
import 'screens/loyalty_screen.dart';
import 'widgets/app_drawer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: CupertinoColors.darkBackgroundGray,
          foregroundColor: CupertinoColors.white,
        ),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkshopScreen(),
    const CashierScreen(),
    const TransactionHistoryScreen(),
    const TechnicianManagementScreen(),
    const BookingScreen(),
    const NotificationScreen(),
    const AnalyticsScreen(),
    const DebtManagementScreen(),
    const LoyaltyScreen(),
    const PrinterSettingsScreen(),
    const AboutScreen(),
    const AboutSchoolScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Workshop',
    'Kasir',
    'Riwayat Transaksi',
    'Manajemen Teknisi',
    'Booking Online',
    'Notifikasi',
    'Analitik Bisnis',
    'Manajemen Hutang',
    'Program Loyalty',
    'Pengaturan Printer',
    'Tentang Aplikasi',
    'Tentang Sekolah',
  ];

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: AppDrawer(
          currentIndex: _currentIndex,
          onItemSelected: _onItemSelected,
        ),
      ),
      body: _screens[_currentIndex],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _scaffoldKey.currentState?.openDrawer();
      //   },
      //   backgroundColor: CupertinoColors.darkBackgroundGray,
      //   child: const Icon(Icons.settings, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
