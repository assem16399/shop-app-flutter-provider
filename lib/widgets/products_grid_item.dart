import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';
import '../screens/product_details_screen.dart';

class ProductsGridItem extends StatelessWidget {
  // final String? productId;
  // final String? title;
  // final String? imageUrl;
  //
  // ProductsGridItem({this.productId, this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    final productData = Provider.of<Product>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ProductDetailsScreen.routeName,
            arguments: productData.id);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GridTile(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: productData.id!,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(
                  productData.imageUrl ?? '',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          footer: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: GridTileBar(
              backgroundColor: Colors.black87,
              leading: IconButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  try {
                    await productData.toggleFavoriteStatus(
                        authData.tokenGetter, authData.userIdGetter);
                  } on TimeoutException catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Timeout! please try again!')));
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  }
                },
                icon: Consumer<Product>(
                  builder: (context, product, child) => Icon(
                    (product.isFavorite)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              ),
              title: Center(child: Text(productData.title ?? '')),
              trailing: IconButton(
                onPressed: () {
                  cartData.addCartItem(productData.id ?? '',
                      productData.title ?? '', productData.price ?? 0);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Item is added successfully',
                      ),
                      action: SnackBarAction(
                        onPressed: () {
                          cartData.deleteOneItem(productData.id!);
                        },
                        label: 'UNDO',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add_shopping_cart,
                ),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
