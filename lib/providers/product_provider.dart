import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  List<Product> get products => [..._products];
  List<String> get categories => [..._categories];
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _databaseService.getProducts();
      _categories = await _databaseService.getCategories();
    } catch (error) {
      debugPrint('Error fetching products: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _databaseService.insertProduct(product);
      final newProduct = Product(
        id: id,
        name: product.name,
        price: product.price,
        category: product.category,
        isAvailable: product.isAvailable,
      );
      _products.add(newProduct);
      
      if (!_categories.contains(product.category)) {
        _categories.add(product.category);
        _categories.sort();
      }
    } catch (error) {
      debugPrint('Error adding product: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product;
      }
      
      // Update categories if needed
      if (!_categories.contains(product.category)) {
        _categories.add(product.category);
        _categories.sort();
      }
    } catch (error) {
      debugPrint('Error updating product: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      
      // Refresh categories
      _categories = await _databaseService.getCategories();
    } catch (error) {
      debugPrint('Error deleting product: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
}