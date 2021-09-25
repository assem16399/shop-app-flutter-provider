import 'package:flutter/foundation.dart';

class CartItem {
  final String? id;
  final String? title;
  final int? quantity;
  final double? price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  void addCartItem(String productId, String title, double price) {
    //check if the item we will add is already exists in the cart or no
    if (_items.containsKey(productId)) {
      //change the quantity...
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity! + 1));
    } else {
      // create a new cart item..
      final cartItem = CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price);

      // add this created cart Item
      _items.putIfAbsent(productId, () => cartItem);
    }

    notifyListeners();
  }

  void deleteCartItem(String productId) {
    if (_items.containsKey(productId)) _items.remove(productId);
    notifyListeners();
  }

  void deleteOneItem(String productId) {
    if (!_items.containsKey(productId)) return;
    _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity! - 1,
            price: existingCartItem.price));
    if (_items[productId]!.quantity == 0) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearTheCart() {
    _items.clear();
    notifyListeners();
  }

  int get cartItemsQuantity {
    return _items.length;
  }

  int get totalCartQuantity {
    var total = 0;
    _items.forEach((key, value) {
      total = value.quantity! + total;
    });
    return total;
  }

  double get totalAmount {
    var totalAmount = 0.0;
    _items.forEach((key, value) {
      totalAmount += value.price! * value.quantity!;
    });
    return totalAmount;
  }
}
