import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class ProductGrid extends StatelessWidget {
  final String? category;

  const ProductGrid({
    super.key,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final products = category == null
        ? productProvider.products
        : productProvider.getProductsByCategory(category!);
    
    if (products.isEmpty) {
      return const Center(
        child: Text('لا توجد منتجات في هذه الفئة'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, index) {
        final product = products[index];
        return _buildProductItem(context, product, cartProvider);
      },
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    Product product,
    CartProvider cartProvider,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: product.isAvailable
            ? () {
                _showAddToCartDialog(context, product, cartProvider);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: product.isAvailable ? null : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: product.isAvailable ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.price.toStringAsFixed(2)} ريال',
                style: TextStyle(
                  color: product.isAvailable ? Colors.green : Colors.grey,
                ),
              ),
              if (!product.isAvailable)
                const Text(
                  'غير متوفر',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartDialog(
    BuildContext context,
    Product product,
    CartProvider cartProvider,
  ) {
    int quantity = 1;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('السعر: ${product.price.toStringAsFixed(2)} ريال'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1
                          ? () {
                              setState(() {
                                quantity--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
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
                  List<String> notes = [];
                  if (notesController.text.isNotEmpty) {
                    notes.add(notesController.text);
                  }
                  
                  cartProvider.addItem(
                    product,
                    quantity: quantity,
                    notes: notes,
                  );
                  
                  Navigator.of(ctx).pop();
                  
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة ${product.name} إلى السلة'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'تراجع',
                        onPressed: () {
                          cartProvider.removeItem(product.id);
                        },
                      ),
                    ),
                  );
                },
                child: const Text('إضافة إلى السلة'),
              ),
            ],
          );
        },
      ),
    );
  }
}