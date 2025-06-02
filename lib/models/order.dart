import 'cart_item.dart';

class Order {
  final int id;
  final List<CartItem> items;
  final DateTime dateTime;
  final double totalAmount;
  final String orderType; // للمطعم، للتوصيل، للاستلام
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String paymentMethod; // نقدي، بطاقة، إلخ

  Order({
    required this.id,
    required this.items,
    required this.dateTime,
    required this.totalAmount,
    required this.orderType,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.paymentMethod,
  });

  // Convert an Order into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'totalAmount': totalAmount,
      'orderType': orderType,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'paymentMethod': paymentMethod,
    };
  }

  // Create an Order from a Map
  factory Order.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    return Order(
      id: map['id'],
      items: items,
      dateTime: DateTime.parse(map['dateTime']),
      totalAmount: map['totalAmount'],
      orderType: map['orderType'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerAddress: map['customerAddress'],
      paymentMethod: map['paymentMethod'],
    );
  }
}