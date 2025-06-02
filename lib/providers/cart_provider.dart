import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Product product, {int quantity = 1, List<String>? notes}) {
    if (_items.containsKey(product.id)) {
      // Update existing item
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + quantity,
          notes: notes ?? existingCartItem.notes,
        ),
      );
    } else {
      // Add new item
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: quantity,
          notes: notes,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateItemQuantity(int productId, int quantity) {
    if (_items.containsKey(productId) && quantity > 0) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: quantity,
          notes: existingCartItem.notes,
        ),
      );
      notifyListeners();
    } else if (quantity <= 0) {
      removeItem(productId);
    }
  }

  void updateItemNotes(int productId, List<String> notes) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity,
          notes: notes,
        ),
      );
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  List<CartItem> get cartItems {
    return _items.values.toList();
  }
}