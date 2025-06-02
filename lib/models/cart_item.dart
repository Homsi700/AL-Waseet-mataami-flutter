import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final List<String> notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    List<String>? notes,
  }) : notes = notes ?? [];

  double get totalPrice => product.price * quantity;

  // Create a copy of this CartItem with given attributes
  CartItem copyWith({
    Product? product,
    int? quantity,
    List<String>? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}