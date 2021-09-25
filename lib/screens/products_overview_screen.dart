import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions { showAll, showFavorites }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavoritesOnly = false;
  Future? _productsFuture;
  Future _obtainProductsFuture() {
    return Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts();
  }

  @override
  void initState() {
    // TODO: implement initState
    _productsFuture = _obtainProductsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Show All'),
                  value: FilterOptions.showAll,
                ),
                PopupMenuItem(
                  child: Text('Show Favorites'),
                  value: FilterOptions.showFavorites,
                ),
              ],
              onSelected: (value) {
                if (value == FilterOptions.showAll) {
                  setState(() {
                    _showFavoritesOnly = false;
                  });
                } else if (value == FilterOptions.showFavorites) {
                  setState(() {
                    _showFavoritesOnly = true;
                  });
                }
              },
            ),
            Consumer<Cart>(
              builder: (context, cartData, child) => Badge(
                  child: child!, value: cartData.totalCartQuantity.toString()),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart),
              ),
            )
          ],
          title: const Text('My Shop'),
        ),
        body: FutureBuilder(
          future: _productsFuture,
          builder: (context, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapShot.error != null) {
                Future.delayed(Duration.zero).then((_) =>
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(dataSnapShot.error
                                .toString()
                                .contains('Timeout')
                            ? 'Timeout!, please check your Internet Connection and try again!'
                            : 'Something went wrong!'))));
                return Center(
                  child: Text('An Error Occurred! '),
                );
              } else {
                return ProductsGrid(_showFavoritesOnly);
              }
            }
          },
        ));
  }
}
