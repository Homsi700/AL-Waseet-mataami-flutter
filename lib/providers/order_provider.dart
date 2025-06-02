import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _databaseService.getOrders();
    } catch (error) {
      debugPrint('Error fetching orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrderById(int id) async {
    try {
      return await _databaseService.getOrderById(id);
    } catch (error) {
      debugPrint('Error getting order by id: $error');
      return null;
    }
  }

  Future<int> addOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required String orderType,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newOrder = Order(
        id: 0, // Will be set by the database
        items: cartItems,
        dateTime: DateTime.now(),
        totalAmount: totalAmount,
        orderType: orderType,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        paymentMethod: paymentMethod,
      );

      final orderId = await _databaseService.insertOrder(newOrder, cartItems);
      
      // Fetch the order with the correct ID
      final createdOrder = await _databaseService.getOrderById(orderId);
      if (createdOrder != null) {
        _orders.insert(0, createdOrder);
      }
      
      return orderId;
    } catch (error) {
      debugPrint('Error adding order: $error');
      return -1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's orders
  List<Order> getTodayOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _orders.where((order) {
      final orderDate = DateTime(
        order.dateTime.year,
        order.dateTime.month,
        order.dateTime.day,
      );
      return orderDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get orders by date range
  List<Order> getOrdersByDateRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    return _orders.where((order) {
      return order.dateTime.isAfter(startDate) && 
             order.dateTime.isBefore(endDate);
    }).toList();
  }

  // Calculate total sales for a list of orders
  double calculateTotalSales(List<Order> orderList) {
    double total = 0.0;
    for (var order in orderList) {
      total += order.totalAmount;
    }
    return total;
  }
}