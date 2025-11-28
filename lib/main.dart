import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/main_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/cashier_controller.dart';
import 'controllers/workshop_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/technician_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/cashier_screen.dart';
import 'screens/workshop_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/technician_management_screen.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://wsutnrbmgqhrtwggpvhj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzdXRucmJtZ3FocnR3Z2dwdmhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3OTQ5NzMsImV4cCI6MjA0ODM3MDk3M30.4cC2JYOkyvQ0Cq0yL8fFJQXs7kYf3vX1v8v4v6v8v9v0v',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final mainController = Get.put(MainController());
    Get.put(DashboardController());
    Get.put(CashierController());
    Get.put(WorkshopController());
    Get.put(TransactionController());
    Get.put(TechnicianController());

    return GetMaterialApp(
      title: 'Workshop Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: CupertinoColors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: CupertinoColors.darkBackgroundGray,
          foregroundColor: CupertinoColors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return Obx(() {
      return Scaffold(
        key: controller.scaffoldKey,
        drawer: AppDrawer(
          currentIndex: controller.currentIndex.value,
          onItemSelected: (index) {
            controller.navigateToScreen(index);
            Navigator.pop(context); // Close drawer
          },
        ),
        body: controller.currentScreen,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            border: Border(
              top: BorderSide(
                color: CupertinoColors.systemGrey4.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: CupertinoIcons.home,
                    label: 'Dashboard',
                    index: 0,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.cart,
                    label: 'Kasir',
                    index: 1,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.wrench,
                    label: 'Bengkel',
                    index: 2,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.list_bullet,
                    label: 'Transaksi',
                    index: 3,
                    controller: controller,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.person_2,
                    label: 'Teknisi',
                    index: 4,
                    controller: controller,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required MainController controller,
  }) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? CupertinoColors.systemBlue
                  : CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.systemGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        onPressed: () => controller.changeIndex(index),
      );
    });
  }
}
