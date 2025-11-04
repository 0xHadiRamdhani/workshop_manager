import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workshop_screen.dart';
import 'screens/cashier_screen.dart';
import 'models/vehicle.dart';
import 'models/transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const WorkshopManagerApp());
}

class WorkshopManagerApp extends StatelessWidget {
  const WorkshopManagerApp({super.key});

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
            return _screens[index];
          },
        );
      },
    );
  }
}
