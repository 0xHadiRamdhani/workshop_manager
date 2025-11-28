import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../screens/dashboard_screen.dart';
import '../screens/cashier_screen.dart';
import '../screens/workshop_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/technician_management_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/debt_management_screen.dart';
import '../screens/loyalty_screen.dart';
import '../screens/printer_settings_screen.dart';
import '../screens/supabase_settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/about_school_screen.dart';
import '../screens/migration_screen.dart';

class MainController extends GetxController {
  // Observable for current index
  var currentIndex = 0.obs;

  // Global key for scaffold
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // List of screens for main navigation (bottom navigation)
  final List<Widget> mainScreens = [
    const DashboardScreen(),
    const CashierScreen(),
    const WorkshopScreen(),
    const TransactionHistoryScreen(),
    const TechnicianManagementScreen(),
  ];

  // Map of all available screens for drawer navigation
  final Map<int, Widget> allScreens = {
    0: const DashboardScreen(),
    1: const WorkshopScreen(),
    2: const CashierScreen(),
    3: const TransactionHistoryScreen(),
    4: const TechnicianManagementScreen(),
    5: const BookingScreen(),
    6: const NotificationScreen(),
    7: const AnalyticsScreen(),
    8: const DebtManagementScreen(),
    9: const LoyaltyScreen(),
    10: const PrinterSettingsScreen(),
    11: const SupabaseSettingsScreen(),
    12: const AboutScreen(),
    13: const AboutSchoolScreen(),
    14: const MigrationScreen(),
  };

  // Change index method - handles both main and drawer navigation
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Get current screen - prioritizes main screens for bottom navigation
  Widget get currentScreen {
    if (currentIndex.value >= 0 && currentIndex.value < mainScreens.length) {
      return mainScreens[currentIndex.value];
    } else if (allScreens.containsKey(currentIndex.value)) {
      return allScreens[currentIndex.value]!;
    } else {
      return mainScreens[0]; // Fallback to dashboard
    }
  }

  // Method to open drawer
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  // Method to navigate to specific screen by index
  void navigateToScreen(int index) {
    changeIndex(index);
  }
}
