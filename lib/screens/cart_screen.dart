import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders_provider.dart';
import '../widgets/cart_list_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Chip(
                      label: FittedBox(
                        child: Text(
                          '\$${cartData.totalAmount.toStringAsFixed(2)}',
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6!
                                  .color),
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : TextButton(
                              onPressed: (cartData.items.length == 0)
                                  ? null
                                  : () async {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await Provider.of<OrdersProvider>(
                                                context,
                                                listen: false)
                                            .addOrder(
                                          cartData.totalAmount,
                                          cartData.items.values.toList(),
                                        );
                                        cartData.clearTheCart();
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      } catch (error) {
                                        await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  content:
                                                      Text('An error occurred'),
                                                  title: Text(
                                                      'Order can\'t be added'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    )
                                                  ],
                                                ));
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              child: const FittedBox(child: Text('ORDER NOW')),
                            ))
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: cartData.cartItemsQuantity,
              itemBuilder: (context, index) => CartListItem(
                  productId: cartData.items.keys.toList()[index],
                  id: cartData.items.values.toList()[index].id,
                  price: cartData.items.values.toList()[index].price,
                  quantity: cartData.items.values.toList()[index].quantity,
                  title: cartData.items.values.toList()[index].title),
            ),
          )
        ],
      ),
    );
  }
}
