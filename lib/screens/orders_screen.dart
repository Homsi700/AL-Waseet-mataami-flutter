import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../services/print_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<OrderProvider>(context).fetchOrders().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تفاصيل الطلب #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(order.dateTime)}'),
              Text('نوع الطلب: ${order.orderType}'),
              Text('طريقة الدفع: ${order.paymentMethod}'),
              if (order.customerName != null && order.customerName!.isNotEmpty)
                Text('العميل: ${order.customerName}'),
              if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                Text('الهاتف: ${order.customerPhone}'),
              if (order.customerAddress != null && order.customerAddress!.isNotEmpty)
                Text('العنوان: ${order.customerAddress}'),
              const Divider(),
              const Text('المنتجات:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.quantity}x ${item.product.name} - ${item.totalPrice.toStringAsFixed(2)} ريال'),
                    if (item.notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          'ملاحظات: ${item.notes.join(', ')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
              const Divider(),
              Text(
                'الإجمالي: ${order.totalAmount.toStringAsFixed(2)} ريال',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              PrintService().printReceipt(order);
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات السابقة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات سابقة'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text('طلب #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(order.dateTime),
                            ),
                            Text(
                              '${order.items.length} عناصر - ${order.totalAmount.toStringAsFixed(2)} ريال',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print),
                              onPressed: () {
                                PrintService().printReceipt(order);
                              },
                              color: Colors.blue,
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _showOrderDetails(order),
                              color: Colors.green,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _showOrderDetails(order),
                      ),
                    );
                  },
                ),
    );
  }
}