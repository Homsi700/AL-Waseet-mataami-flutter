import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/cart_item.dart';
import '../services/print_service.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        children: [
          AppBar(
            title: const Text('سلة المشتريات'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text(
                              'هل أنت متأكد من حذف جميع العناصر من السلة؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  cartProvider.clear();
                                  Navigator.of(ctx).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                      },
              ),
            ],
          ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text('السلة فارغة'),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      return _buildCartItem(context, cartItems[index], cartProvider);
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cartProvider.totalAmount.toStringAsFixed(2)} ريال',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCheckoutDialog(context, cartProvider, orderProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'إتمام الطلب',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    cartProvider.removeItem(cartItem.product.id);
                  },
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${cartItem.product.price.toStringAsFixed(2)} ريال'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: cartItem.quantity > 1
                          ? () {
                              cartProvider.updateItemQuantity(
                                cartItem.product.id,
                                cartItem.quantity - 1,
                              );
                            }
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        cartProvider.updateItemQuantity(
                          cartItem.product.id,
                          cartItem.quantity + 1,
                        );
                      },
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            if (cartItem.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ملاحظات: ${cartItem.notes.join(', ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'الإجمالي: ${cartItem.totalPrice.toStringAsFixed(2)} ريال',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(
    BuildContext context,
    CartProvider cartProvider,
    OrderProvider orderProvider,
  ) {
    final _formKey = GlobalKey<FormState>();
    String orderType = 'للمطعم';
    String paymentMethod = 'نقدي';
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final customerAddressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إتمام الطلب'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نوع الطلب:'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('للمطعم'),
                          selected: orderType == 'للمطعم',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                orderType = 'للمطعم';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('للتوصيل'),
                          selected: orderType == 'للتوصيل',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                orderType = 'للتوصيل';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('للاستلام'),
                          selected: orderType == 'للاستلام',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                orderType = 'للاستلام';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('طريقة الدفع:'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('نقدي'),
                          selected: paymentMethod == 'نقدي',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                paymentMethod = 'نقدي';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('بطاقة'),
                          selected: paymentMethod == 'بطاقة',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                paymentMethod = 'بطاقة';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (orderType != 'للمطعم')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('معلومات العميل:'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم العميل',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (orderType != 'للمطعم' &&
                                  (value == null || value.isEmpty)) {
                                return 'الرجاء إدخال اسم العميل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: customerPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (orderType != 'للمطعم' &&
                                  (value == null || value.isEmpty)) {
                                return 'الرجاء إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          if (orderType == 'للتوصيل')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextFormField(
                                controller: customerAddressController,
                                decoration: const InputDecoration(
                                  labelText: 'العنوان',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                                validator: (value) {
                                  if (orderType == 'للتوصيل' &&
                                      (value == null || value.isEmpty)) {
                                    return 'الرجاء إدخال العنوان';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cartProvider.totalAmount.toStringAsFixed(2)} ريال',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final orderId = await orderProvider.addOrder(
                      cartItems: cartProvider.cartItems,
                      totalAmount: cartProvider.totalAmount,
                      orderType: orderType,
                      customerName: customerNameController.text.isEmpty
                          ? null
                          : customerNameController.text,
                      customerPhone: customerPhoneController.text.isEmpty
                          ? null
                          : customerPhoneController.text,
                      customerAddress: customerAddressController.text.isEmpty
                          ? null
                          : customerAddressController.text,
                      paymentMethod: paymentMethod,
                    );
                    
                    if (orderId > 0) {
                      cartProvider.clear();
                      Navigator.of(ctx).pop();
                      
                      // Show success dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تم إنشاء الطلب بنجاح'),
                          content: Text('رقم الطلب: $orderId'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('إغلاق'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final order = await orderProvider.getOrderById(orderId);
                                if (order != null) {
                                  PrintService().printReceipt(order);
                                }
                              },
                              icon: const Icon(Icons.print),
                              label: const Text('طباعة الفاتورة'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Show error dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('خطأ'),
                          content: const Text('حدث خطأ أثناء إنشاء الطلب. الرجاء المحاولة مرة أخرى.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: const Text('تأكيد الطلب'),
              ),
            ],
          );
        },
      ),
    );
  }
}