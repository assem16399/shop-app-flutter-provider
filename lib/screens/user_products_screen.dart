import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_products_list_item.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    _isLoading = true;
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      Future.delayed(Duration.zero).then((value) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Something went wrong!'))));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Your Products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              })
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Provider.of<ProductsProvider>(context, listen: false)
                    .fetchAndSetProducts(true);
              },
              child: Consumer<ProductsProvider>(
                builder: (context, productsData, _) => ListView.builder(
                    itemExtent: productsData.products.length == 0
                        ? MediaQuery.of(context).size.height * 0.8
                        : null,
                    padding: EdgeInsets.all(8),
                    itemCount: productsData.products.length == 0
                        ? 1
                        : productsData.products.length,
                    itemBuilder: (context, index) =>
                        (productsData.products.length == 0)
                            ? Center(
                                child: Text(
                                  'You don\'t have any products, start adding some!',
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : UserProductsListItem(
                                id: productsData.products[index].id!,
                                title: productsData.products[index].title!,
                                imageUrl:
                                    productsData.products[index].imageUrl!)),
              ),
            ),
    );
  }
}
