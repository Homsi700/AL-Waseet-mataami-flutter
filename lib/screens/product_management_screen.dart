import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
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

  void _showProductDialog({Product? product}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product?.name ?? '');
    final _priceController = TextEditingController(text: product?.price.toString() ?? '');
    final _categoryController = TextEditingController(text: product?.category ?? '');
    bool _isAvailable = product?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم المنتج'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المنتج';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'السعر'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال السعر';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الفئة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('متوفر:'),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                
                if (product == null) {
                  // Add new product
                  productProvider.addProduct(
                    Product(
                      id: 0, // Will be set by the database
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      category: _categoryController.text,
                      isAvailable: _isAvailable,
                    ),
                  );
                } else {
                  // Update existing product
                  productProvider.updateProduct(
                    Product(
                      id: product.id,
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      category: _categoryController.text,
                      isAvailable: _isAvailable,
                    ),
                  );
                }
                
                Navigator.of(ctx).pop();
              }
            },
            child: Text(product == null ? 'إضافة' : 'تحديث'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('لا توجد منتجات. أضف منتجات جديدة!'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (ctx, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.price.toStringAsFixed(2)} ريال - ${product.category}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showProductDialog(product: product),
                              color: Colors.blue,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: Text(
                                      'هل أنت متأكد من حذف ${product.name}؟',
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
                                          productProvider.deleteProduct(product.id);
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
                              color: Colors.red,
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: product.isAvailable
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(
                            product.isAvailable
                                ? Icons.check
                                : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}