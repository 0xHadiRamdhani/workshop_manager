import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/vehicle.dart';
import '../models/technician.dart';
import '../models/booking.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/notification.dart' as app_notification;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Getter untuk akses client Supabase
  SupabaseClient get client => _client;

  // ==================== PRODUCT OPERATIONS ====================

  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((json) => _productFromJson(json)).toList();
    } catch (e) {
      print('Error getting products from Supabase: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();
      return _productFromJson(response);
    } catch (e) {
      print('Error getting product by id from Supabase: $e');
      return null;
    }
  }

  Future<bool> insertProduct(Product product) async {
    try {
      final productData = _productToJson(product);
      await _client.from('products').insert(productData);
      return true;
    } catch (e) {
      print('Error inserting product to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final productData = _productToJson(product);
      await _client.from('products').update(productData).eq('id', product.id);
      return true;
    } catch (e) {
      print('Error updating product in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting product from Supabase: $e');
      return false;
    }
  }

  // ==================== VEHICLE OPERATIONS ====================

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((json) => _vehicleFromJson(json)).toList();
    } catch (e) {
      print('Error getting vehicles from Supabase: $e');
      return [];
    }
  }

  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .eq('id', id)
          .single();
      return _vehicleFromJson(response);
    } catch (e) {
      print('Error getting vehicle by id from Supabase: $e');
      return null;
    }
  }

  Future<bool> insertVehicle(Vehicle vehicle) async {
    try {
      final vehicleData = _vehicleToJson(vehicle);
      await _client.from('vehicles').insert(vehicleData);
      return true;
    } catch (e) {
      print('Error inserting vehicle to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicleData = _vehicleToJson(vehicle);
      await _client.from('vehicles').update(vehicleData).eq('id', vehicle.id);
      return true;
    } catch (e) {
      print('Error updating vehicle in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      await _client.from('vehicles').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting vehicle from Supabase: $e');
      return false;
    }
  }

  // ==================== TECHNICIAN OPERATIONS ====================

  Future<List<Technician>> getTechnicians() async {
    try {
      final response = await _client
          .from('technicians')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => _technicianFromJson(json))
          .toList();
    } catch (e) {
      print('Error getting technicians from Supabase: $e');
      return [];
    }
  }

  Future<Technician?> getTechnicianById(String id) async {
    try {
      final response = await _client
          .from('technicians')
          .select()
          .eq('id', id)
          .single();
      return _technicianFromJson(response);
    } catch (e) {
      print('Error getting technician by id from Supabase: $e');
      return null;
    }
  }

  Future<bool> insertTechnician(Technician technician) async {
    try {
      final technicianData = _technicianToJson(technician);
      await _client.from('technicians').insert(technicianData);
      return true;
    } catch (e) {
      print('Error inserting technician to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateTechnician(Technician technician) async {
    try {
      final technicianData = _technicianToJson(technician);
      await _client
          .from('technicians')
          .update(technicianData)
          .eq('id', technician.id);
      return true;
    } catch (e) {
      print('Error updating technician in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteTechnician(String id) async {
    try {
      await _client.from('technicians').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting technician from Supabase: $e');
      return false;
    }
  }

  // ==================== BOOKING OPERATIONS ====================

  Future<List<Booking>> getBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .order('preferred_date', ascending: true);
      return (response as List).map((json) => _bookingFromJson(json)).toList();
    } catch (e) {
      print('Error getting bookings from Supabase: $e');
      return [];
    }
  }

  Future<Booking?> getBookingById(String id) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('id', id)
          .single();
      return _bookingFromJson(response);
    } catch (e) {
      print('Error getting booking by id from Supabase: $e');
      return null;
    }
  }

  Future<bool> insertBooking(Booking booking) async {
    try {
      final bookingData = _bookingToJson(booking);
      await _client.from('bookings').insert(bookingData);
      return true;
    } catch (e) {
      print('Error inserting booking to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateBooking(Booking booking) async {
    try {
      final bookingData = _bookingToJson(booking);
      await _client.from('bookings').update(bookingData).eq('id', booking.id);
      return true;
    } catch (e) {
      print('Error updating booking in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteBooking(String id) async {
    try {
      await _client.from('bookings').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting booking from Supabase: $e');
      return false;
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<List<app_transaction.Transaction>> getTransactions() async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => _transactionFromJson(json))
          .toList();
    } catch (e) {
      print('Error getting transactions from Supabase: $e');
      return [];
    }
  }

  Future<app_transaction.Transaction?> getTransactionById(String id) async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('id', id)
          .single();
      return _transactionFromJson(response);
    } catch (e) {
      print('Error getting transaction by id from Supabase: $e');
      return null;
    }
  }

  Future<bool> insertTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      final transactionData = _transactionToJson(transaction);
      await _client.from('transactions').insert(transactionData);
      return true;
    } catch (e) {
      print('Error inserting transaction to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(
    app_transaction.Transaction transaction,
  ) async {
    try {
      final transactionData = _transactionToJson(transaction);
      await _client
          .from('transactions')
          .update(transactionData)
          .eq('id', transaction.id);
      return true;
    } catch (e) {
      print('Error updating transaction in Supabase: $e');
      return false;
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  Future<List<app_notification.Notification>> getNotifications() async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => _notificationFromJson(json))
          .toList();
    } catch (e) {
      print('Error getting notifications from Supabase: $e');
      return [];
    }
  }

  Future<bool> insertNotification(
    app_notification.Notification notification,
  ) async {
    try {
      final notificationData = _notificationToJson(notification);
      await _client.from('notifications').insert(notificationData);
      return true;
    } catch (e) {
      print('Error inserting notification to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateNotification(
    app_notification.Notification notification,
  ) async {
    try {
      final notificationData = _notificationToJson(notification);
      await _client
          .from('notifications')
          .update(notificationData)
          .eq('id', notification.id);
      return true;
    } catch (e) {
      print('Error updating notification in Supabase: $e');
      return false;
    }
  }

  // ==================== DASHBOARD ANALYTICS ====================

  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      // Get daily transactions
      final dailyTransactions = await _client
          .from('transactions')
          .select()
          .gte('created_at', startOfDay.millisecondsSinceEpoch)
          .lt('created_at', endOfDay.millisecondsSinceEpoch);

      final dailyRevenue = dailyTransactions.fold<double>(0.0, (
        sum,
        transaction,
      ) {
        return sum + (transaction['total_amount'] as double);
      });

      // Get monthly transactions
      final monthlyTransactions = await _client
          .from('transactions')
          .select()
          .gte('created_at', startOfMonth.millisecondsSinceEpoch)
          .lt('created_at', endOfMonth.millisecondsSinceEpoch);

      final monthlyRevenue = monthlyTransactions.fold<double>(0.0, (
        sum,
        transaction,
      ) {
        return sum + (transaction['total_amount'] as double);
      });

      // Get counts
      final products = await _client.from('products').select();
      final vehicles = await _client.from('vehicles').select();
      final technicians = await _client.from('technicians').select();
      final pendingBookings = await _client
          .from('bookings')
          .select()
          .eq('status', 'pending');

      return {
        'dailyRevenue': dailyRevenue,
        'dailyTransactions': dailyTransactions.length,
        'monthlyRevenue': monthlyRevenue,
        'monthlyTransactions': monthlyTransactions.length,
        'pendingBookings': pendingBookings.length,
        'totalProducts': products.length,
        'totalVehicles': vehicles.length,
        'totalTechnicians': technicians.length,
      };
    } catch (e) {
      print('Error getting dashboard analytics from Supabase: $e');
      return {
        'dailyRevenue': 0.0,
        'dailyTransactions': 0,
        'monthlyRevenue': 0.0,
        'monthlyTransactions': 0,
        'pendingBookings': 0,
        'totalProducts': 0,
        'totalVehicles': 0,
        'totalTechnicians': 0,
      };
    }
  }

  // ==================== HELPER METHODS ====================

  // Product helpers
  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      description: json['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'stock': product.stock,
      'description': product.description,
      'created_at': product.createdAt.millisecondsSinceEpoch,
    };
  }

  // Vehicle helpers
  Vehicle _vehicleFromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      customerName: json['customer_name'],
      vehicleType: json['vehicle_type'],
      licensePlate: json['license_plate'],
      phoneNumber: json['phone_number'],
      problemDescription: json['problem_description'],
      status: _parseVehicleStatus(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      estimatedCompletion: json['estimated_completion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['estimated_completion'])
          : null,
      estimatedCost: json['estimated_cost']?.toDouble(),
      paymentMethod: json['payment_method'] != null
          ? _parsePaymentMethod(json['payment_method'])
          : null,
      actualCost: json['actual_cost']?.toDouble(),
      isPaid: json['is_paid'] == true,
    );
  }

  Map<String, dynamic> _vehicleToJson(Vehicle vehicle) {
    return {
      'id': vehicle.id,
      'customer_name': vehicle.customerName,
      'vehicle_type': vehicle.vehicleType,
      'license_plate': vehicle.licensePlate,
      'phone_number': vehicle.phoneNumber,
      'problem_description': vehicle.problemDescription,
      'status': vehicle.status.toString(),
      'created_at': vehicle.createdAt.millisecondsSinceEpoch,
      'estimated_completion':
          vehicle.estimatedCompletion?.millisecondsSinceEpoch,
      'estimated_cost': vehicle.estimatedCost,
      'payment_method': vehicle.paymentMethod?.toString(),
      'actual_cost': vehicle.actualCost,
      'is_paid': vehicle.isPaid,
    };
  }

  // Technician helpers
  Technician _technicianFromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      specialization: json['specialization'],
      experienceYears: json['experience_years'] ?? 0,
      status: _parseTechnicianStatus(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      lastActive: json['last_active'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_active'])
          : null,
      rating: json['rating']?.toDouble() ?? 0.0,
      totalServices: json['total_services'] ?? 0,
      salaryType: _parseSalaryType(json['salary_type']),
      salaryAmount: json['salary_amount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> _technicianToJson(Technician technician) {
    return {
      'id': technician.id,
      'name': technician.name,
      'phone': technician.phone,
      'email': technician.email,
      'specialization': technician.specialization,
      'experience_years': technician.experienceYears,
      'status': technician.status.toString(),
      'created_at': technician.createdAt.millisecondsSinceEpoch,
      'last_active': technician.lastActive?.millisecondsSinceEpoch,
      'rating': technician.rating,
      'total_services': technician.totalServices,
      'salary_type': technician.salaryType.toString(),
      'salary_amount': technician.salaryAmount,
    };
  }

  // Booking helpers
  Booking _bookingFromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      customerName: json['customer_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      vehicleType: json['vehicle_type'],
      licensePlate: json['license_plate'],
      serviceType: json['service_type'],
      preferredDate: DateTime.fromMillisecondsSinceEpoch(
        json['preferred_date'],
      ),
      preferredTime: json['preferred_time'],
      status: _parseBookingStatus(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['confirmed_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'])
          : null,
      technicianId: json['technician_id'],
      estimatedDuration: json['estimated_duration'],
      notes: json['notes'],
      reminderSent: json['reminder_sent'] == true,
    );
  }

  Map<String, dynamic> _bookingToJson(Booking booking) {
    return {
      'id': booking.id,
      'customer_name': booking.customerName,
      'phone_number': booking.phoneNumber,
      'email': booking.email,
      'vehicle_type': booking.vehicleType,
      'license_plate': booking.licensePlate,
      'service_type': booking.serviceType,
      'preferred_date': booking.preferredDate.millisecondsSinceEpoch,
      'preferred_time': booking.preferredTime,
      'status': booking.status.toString(),
      'created_at': booking.createdAt.millisecondsSinceEpoch,
      'confirmed_at': booking.confirmedAt?.millisecondsSinceEpoch,
      'completed_at': booking.completedAt?.millisecondsSinceEpoch,
      'technician_id': booking.technicianId,
      'estimated_duration': booking.estimatedDuration,
      'notes': booking.notes,
      'reminder_sent': booking.reminderSent,
    };
  }

  // Transaction helpers
  app_transaction.Transaction _transactionFromJson(Map<String, dynamic> json) {
    return app_transaction.Transaction(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      customerName: json['customer_name'],
      services: _jsonToServices(json['services']),
      totalAmount: json['total_amount'].toDouble(),
      paymentMethod: _parsePaymentMethod(json['payment_method']),
      status: _parseTransactionStatus(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      paidAt: json['paid_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['paid_at'])
          : null,
      cashAmount: json['cash_amount']?.toDouble(),
      changeAmount: json['change_amount']?.toDouble(),
      isDebt: json['is_debt'] == true,
      debtAmount: json['debt_amount']?.toDouble() ?? 0.0,
      debtPaidAmount: json['debt_paid_amount']?.toDouble() ?? 0.0,
      debtStatus: json['debt_status'] ?? 'paid',
      paymentDueDate: json['payment_due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['payment_due_date'])
          : null,
      branchId: json['branch_id'] ?? 'MAIN',
      invoiceNumber: json['invoice_number'],
    );
  }

  Map<String, dynamic> _transactionToJson(
    app_transaction.Transaction transaction,
  ) {
    return {
      'id': transaction.id,
      'vehicle_id': transaction.vehicleId,
      'customer_name': transaction.customerName,
      'services': _servicesToJson(transaction.services),
      'total_amount': transaction.totalAmount,
      'payment_method': transaction.paymentMethod.toString(),
      'status': transaction.status.toString(),
      'created_at': transaction.createdAt.millisecondsSinceEpoch,
      'paid_at': transaction.paidAt?.millisecondsSinceEpoch,
      'cash_amount': transaction.cashAmount,
      'change_amount': transaction.changeAmount,
      'is_debt': transaction.isDebt,
      'debt_amount': transaction.debtAmount,
      'debt_paid_amount': transaction.debtPaidAmount,
      'debt_status': transaction.debtStatus,
      'payment_due_date': transaction.paymentDueDate?.millisecondsSinceEpoch,
      'branch_id': transaction.branchId,
      'invoice_number': transaction.invoiceNumber,
    };
  }

  // Notification helpers
  app_notification.Notification _notificationFromJson(
    Map<String, dynamic> json,
  ) {
    return app_notification.Notification(
      id: json['id'],
      type: _parseNotificationType(json['type']),
      title: json['title'],
      message: json['message'],
      recipientType: _parseNotificationRecipientType(json['recipient_type']),
      recipientId: json['recipient_id'],
      status: _parseNotificationStatus(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      sentAt: json['sent_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sent_at'])
          : null,
      readAt: json['read_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['read_at'])
          : null,
      relatedId: json['related_id'],
      priority: _parseNotificationPriority(json['priority']),
    );
  }

  Map<String, dynamic> _notificationToJson(
    app_notification.Notification notification,
  ) {
    return {
      'id': notification.id,
      'type': notification.type.toString(),
      'title': notification.title,
      'message': notification.message,
      'recipient_type': notification.recipientType.toString(),
      'recipient_id': notification.recipientId,
      'status': notification.status.toString(),
      'created_at': notification.createdAt.millisecondsSinceEpoch,
      'sent_at': notification.sentAt?.millisecondsSinceEpoch,
      'read_at': notification.readAt?.millisecondsSinceEpoch,
      'related_id': notification.relatedId,
      'priority': notification.priority.toString(),
    };
  }

  // Helper methods for parsing
  String _servicesToJson(List<app_transaction.ServiceItem> services) {
    return services
        .map(
          (service) => '${service.name}|${service.price}|${service.quantity}',
        )
        .join(',');
  }

  List<app_transaction.ServiceItem> _jsonToServices(String servicesJson) {
    return servicesJson.split(',').map((serviceStr) {
      final parts = serviceStr.split('|');
      return app_transaction.ServiceItem(
        name: parts[0],
        price: double.parse(parts[1]),
        quantity: int.parse(parts[2]),
      );
    }).toList();
  }

  VehicleStatus _parseVehicleStatus(String status) {
    switch (status) {
      case 'VehicleStatus.waiting':
        return VehicleStatus.waiting;
      case 'VehicleStatus.inProgress':
        return VehicleStatus.inProgress;
      case 'VehicleStatus.completed':
        return VehicleStatus.completed;
      case 'VehicleStatus.delivered':
        return VehicleStatus.delivered;
      default:
        return VehicleStatus.waiting;
    }
  }

  app_transaction.PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'PaymentMethod.cash':
        return app_transaction.PaymentMethod.cash;
      case 'PaymentMethod.transfer':
        return app_transaction.PaymentMethod.transfer;
      case 'PaymentMethod.card':
        return app_transaction.PaymentMethod.card;
      case 'PaymentMethod.debt':
        return app_transaction.PaymentMethod.debt;
      default:
        return app_transaction.PaymentMethod.cash;
    }
  }

  app_transaction.TransactionStatus _parseTransactionStatus(String status) {
    switch (status) {
      case 'TransactionStatus.pending':
        return app_transaction.TransactionStatus.pending;
      case 'TransactionStatus.paid':
        return app_transaction.TransactionStatus.paid;
      case 'TransactionStatus.cancelled':
        return app_transaction.TransactionStatus.cancelled;
      default:
        return app_transaction.TransactionStatus.pending;
    }
  }

  TechnicianStatus _parseTechnicianStatus(String status) {
    switch (status) {
      case 'TechnicianStatus.active':
        return TechnicianStatus.active;
      case 'TechnicianStatus.inactive':
        return TechnicianStatus.inactive;
      case 'TechnicianStatus.onLeave':
        return TechnicianStatus.onLeave;
      default:
        return TechnicianStatus.active;
    }
  }

  SalaryType _parseSalaryType(String type) {
    switch (type) {
      case 'SalaryType.daily':
        return SalaryType.daily;
      case 'SalaryType.monthly':
        return SalaryType.monthly;
      case 'SalaryType.commission':
        return SalaryType.commission;
      default:
        return SalaryType.daily;
    }
  }

  BookingStatus _parseBookingStatus(String status) {
    switch (status) {
      case 'BookingStatus.pending':
        return BookingStatus.pending;
      case 'BookingStatus.confirmed':
        return BookingStatus.confirmed;
      case 'BookingStatus.inProgress':
        return BookingStatus.inProgress;
      case 'BookingStatus.completed':
        return BookingStatus.completed;
      case 'BookingStatus.cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  app_notification.NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'NotificationType.serviceReminder':
        return app_notification.NotificationType.serviceReminder;
      case 'NotificationType.bookingConfirmation':
        return app_notification.NotificationType.bookingConfirmation;
      case 'NotificationType.paymentDue':
        return app_notification.NotificationType.paymentDue;
      case 'NotificationType.stockAlert':
        return app_notification.NotificationType.stockAlert;
      case 'NotificationType.systemAlert':
        return app_notification.NotificationType.systemAlert;
      default:
        return app_notification.NotificationType.systemAlert;
    }
  }

  app_notification.NotificationRecipientType _parseNotificationRecipientType(
    String type,
  ) {
    switch (type) {
      case 'NotificationRecipientType.customer':
        return app_notification.NotificationRecipientType.customer;
      case 'NotificationRecipientType.technician':
        return app_notification.NotificationRecipientType.technician;
      case 'NotificationRecipientType.manager':
        return app_notification.NotificationRecipientType.manager;
      case 'NotificationRecipientType.system':
        return app_notification.NotificationRecipientType.system;
      default:
        return app_notification.NotificationRecipientType.system;
    }
  }

  app_notification.NotificationStatus _parseNotificationStatus(String status) {
    switch (status) {
      case 'NotificationStatus.pending':
        return app_notification.NotificationStatus.pending;
      case 'NotificationStatus.sent':
        return app_notification.NotificationStatus.sent;
      case 'NotificationStatus.read':
        return app_notification.NotificationStatus.read;
      case 'NotificationStatus.failed':
        return app_notification.NotificationStatus.failed;
      default:
        return app_notification.NotificationStatus.pending;
    }
  }

  app_notification.NotificationPriority _parseNotificationPriority(
    String priority,
  ) {
    switch (priority) {
      case 'NotificationPriority.low':
        return app_notification.NotificationPriority.low;
      case 'NotificationPriority.medium':
        return app_notification.NotificationPriority.medium;
      case 'NotificationPriority.high':
        return app_notification.NotificationPriority.high;
      case 'NotificationPriority.urgent':
        return app_notification.NotificationPriority.urgent;
      default:
        return app_notification.NotificationPriority.medium;
    }
  }
}
