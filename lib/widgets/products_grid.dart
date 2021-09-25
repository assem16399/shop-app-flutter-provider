import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/products_grid_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  ProductsGrid(this.showFavorites);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context);
    final products =
        (showFavorites) ? productData.favoriteProducts : productData.products;

    return (products.length == 0)
        ? Center(
            child: Text(
              'No Products Available!',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductsGridItem(
                  // productId: products[index].id,
                  // imageUrl: products[index].imageUrl,
                  // title: products[index].title,
                  ),
            ),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5 / 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20),
          );
  }
}
