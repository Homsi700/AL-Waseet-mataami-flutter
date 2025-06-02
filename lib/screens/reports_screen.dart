import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _reportType = 'daily'; // daily, weekly, monthly, custom

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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<Order> _getFilteredOrders() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    switch (_reportType) {
      case 'daily':
        return orderProvider.getTodayOrders();
      case 'weekly':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return orderProvider.getOrdersByDateRange(startDate, now);
      case 'monthly':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return orderProvider.getOrdersByDateRange(startOfMonth, now);
      case 'custom':
        return orderProvider.getOrdersByDateRange(_startDate, _endDate);
      default:
        return [];
    }
  }

  Map<String, double> _calculateCategorySales(List<Order> orders) {
    Map<String, double> categorySales = {};
    
    for (var order in orders) {
      for (var item in order.items) {
        final category = item.product.category;
        if (categorySales.containsKey(category)) {
          categorySales[category] = categorySales[category]! + item.totalPrice;
        } else {
          categorySales[category] = item.totalPrice;
        }
      }
    }
    
    return categorySales;
  }

  Map<String, int> _calculateProductSales(List<Order> orders) {
    Map<String, int> productSales = {};
    
    for (var order in orders) {
      for (var item in order.items) {
        final productName = item.product.name;
        if (productSales.containsKey(productName)) {
          productSales[productName] = productSales[productName]! + item.quantity;
        } else {
          productSales[productName] = item.quantity;
        }
      }
    }
    
    return productSales;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final filteredOrders = _getFilteredOrders();
    final totalSales = orderProvider.calculateTotalSales(filteredOrders);
    final categorySales = _calculateCategorySales(filteredOrders);
    final productSales = _calculateProductSales(filteredOrders);
    
    // Sort products by sales (descending)
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get top 5 products
    final topProducts = sortedProducts.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report type selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نوع التقرير:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('اليوم'),
                                selected: _reportType == 'daily',
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _reportType = 'daily';
                                    });
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('الأسبوع'),
                                selected: _reportType == 'weekly',
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _reportType = 'weekly';
                                    });
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('الشهر'),
                                selected: _reportType == 'monthly',
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _reportType = 'monthly';
                                    });
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('مخصص'),
                                selected: _reportType == 'custom',
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _reportType = 'custom';
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if (_reportType == 'custom')
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _selectDate(context, true),
                                      icon: const Icon(Icons.calendar_today),
                                      label: Text(
                                        DateFormat('yyyy-MM-dd').format(_startDate),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _selectDate(context, false),
                                      icon: const Icon(Icons.calendar_today),
                                      label: Text(
                                        DateFormat('yyyy-MM-dd').format(_endDate),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص المبيعات',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('إجمالي المبيعات:'),
                              Text(
                                '${totalSales.toStringAsFixed(2)} ريال',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('عدد الطلبات:'),
                              Text(
                                '${filteredOrders.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (filteredOrders.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('متوسط قيمة الطلب:'),
                                  Text(
                                    '${(totalSales / filteredOrders.length).toStringAsFixed(2)} ريال',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Top products
                  if (topProducts.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'أكثر المنتجات مبيعاً',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Divider(),
                            ...topProducts.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '${entry.value} قطعة',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Sales by category
                  if (categorySales.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المبيعات حسب الفئة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Divider(),
                            ...categorySales.entries.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '${entry.value.toStringAsFixed(2)} ريال',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}