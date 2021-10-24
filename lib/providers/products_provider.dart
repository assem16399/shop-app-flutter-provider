import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/HttpException.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? price;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.imageUrl,
      @required this.price,
      this.isFavorite = false});

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Future<void> toggleFavoriteStatus(String? authToken, String? userId) async {
    final url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/user-favorites/$userId/$id.json?auth=$authToken');

    this.isFavorite = !this.isFavorite;
    notifyListeners();
    try {
      final response = await http
          .put(url, body: jsonEncode(this.isFavorite))
          .timeout(Duration(seconds: 3));
      if (response.statusCode >= 400) {
        this.isFavorite = !this.isFavorite;
        notifyListeners();
        throw HttpException('Something went wrong!');
      }
    } on TimeoutException catch (error) {
      this.isFavorite = !this.isFavorite;
      notifyListeners();
      throw error;
    }
  }
}

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String? authToken;
  String? userId;
  ProductsProvider(this._products, {this.authToken, this.userId});

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite == true).toList();
  }

  Product findProductById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterByUserCondition =
        filterByUser == false ? '' : '&orderBy="userId"&equalTo="$userId"';
    var url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/products.json?auth=$authToken$filterByUserCondition');
    try {
      final response = await http.get(url).timeout(Duration(seconds: 30));

      if (json.decode(response.body) == null) {
        return;
      }
      url = Uri.parse(
          'Put here Your Firebase Real Time DB URL/user-favorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavorite: jsonDecode(favoriteResponse.body) == null
                ? false
                : favoriteData[productId] ?? false));
      });
      _products = loadedProducts;
      notifyListeners();
    } on TimeoutException catch (error) {
      throw error;
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'userId': userId,
          }));

      _products.add(product.copyWith(id: jsonDecode(response.body)['name']));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product editedProduct) async {
    final url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/products/$id.json?auth=$authToken');

    final response = await http.patch(url,
        body: jsonEncode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price,
          'imageUrl': editedProduct.imageUrl,
        }));
    if (response.statusCode >= 400) {
      throw HttpException('Item Could not be updated!');
    } else {
      final productIndex = _products.indexWhere((product) => product.id == id);
      _products[productIndex] = editedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    var url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/products/$id.json?auth=$authToken');

    final productIndex = _products.indexWhere((product) => product.id == id);
    Product? product = _products[productIndex];
    _products.removeAt(productIndex);
    notifyListeners();

    final response = await http.delete(url);
    url = Uri.parse(
        'Put here Your Firebase Real Time DB URL/user-favorites/$userId/$id.json?auth=$authToken');
    await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(productIndex, product);
      notifyListeners();
      throw HttpException('Item Could not be deleted');
    } else {
      product = null;
    }
  }

  void updateUser(String? token, String? id) {
    this.userId = id;
    this.authToken = token;
    notifyListeners();
  }
}
