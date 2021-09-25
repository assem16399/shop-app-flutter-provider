import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_application/providers/cart.dart';
import 'package:http/http.dart' as http;

class Order {
  final String id;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime dateTime;

  Order(
      {required this.id,
      required this.totalAmount,
      required this.products,
      required this.dateTime});
}

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  String? authToken;
  String? userId;
  OrdersProvider(this._orders, this.authToken, this.userId);

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-application-flutter-3a99a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      if (jsonDecode(response.body) == null) return;
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Order> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(Order(
            id: orderId,
            dateTime: DateTime.parse(orderData['dateTime']),
            totalAmount: orderData['totalAmount'],
            products: (orderData['order'] as List<dynamic>)
                .map((cartItem) => CartItem(
                    id: cartItem['id'],
                    title: cartItem['title'],
                    quantity: cartItem['quantity'],
                    price: cartItem['price']))
                .toList()));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(double totalAmount, List<CartItem> order) async {
    final url = Uri.parse(
        'https://shop-application-flutter-3a99a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final date = DateTime.now();
      final response = await http.post(url,
          body: jsonEncode({
            'totalAmount': totalAmount,
            'dateTime': date.toIso8601String(),
            'order': order
                .map((cartItem) => {
                      'id': cartItem.id,
                      'title': cartItem.title,
                      'price': cartItem.price,
                      'quantity': cartItem.quantity
                    })
                .toList()
          }));
      _orders.insert(
          0,
          Order(
              id: jsonDecode(response.body)['name'],
              totalAmount: totalAmount,
              products: order,
              dateTime: date));

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void updateUser(String? token, String? id) {
    this.userId = id;
    this.authToken = token;
    notifyListeners();
  }
}
