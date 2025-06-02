import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_drawer.dart';
import 'product_management_screen.dart';
import 'orders_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'الكل';
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final categories = ['الكل', ...productProvider.categories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوسيط - نقطة البيع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const OrdersScreen(),
                ),
              );
            },
            tooltip: 'الطلبات السابقة',
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ReportsScreen(),
                ),
              );
            },
            tooltip: 'التقارير',
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ProductManagementScreen(),
                ),
              );
            },
            tooltip: 'إدارة المنتجات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Categories
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(categories[index]),
                          selected: _selectedCategory == categories[index],
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = categories[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Products grid
                Expanded(
                  child: ProductGrid(
                    category: _selectedCategory == 'الكل' ? null : _selectedCategory,
                  ),
                ),
              ],
            ),
      endDrawer: cartProvider.itemCount > 0 ? const CartDrawer() : null,
      floatingActionButton: cartProvider.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              label: Text('${cartProvider.itemCount} عناصر'),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}