import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartListItem extends StatelessWidget {
  final String? productId;
  final String? id;
  final double? price;
  final int? quantity;
  final String? title;

  CartListItem({
    @required this.id,
    @required this.price,
    @required this.quantity,
    @required this.title,
    @required this.productId,
  });

  Future<bool> alert(BuildContext context) async => await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Are you Sure?'),
            content: Text('Do you want to delete this item from the cart?'),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .deleteCartItem(productId!);
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('NO'),
              ),
            ],
          ));

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (dismissDirection) async => await alert(context),
      onDismissed: (dismissDirection) {
        if (dismissDirection == DismissDirection.endToStart) {
          Provider.of<Cart>(context, listen: false).deleteCartItem(productId!);
        }
      },
      key: ValueKey(id),
      background: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(2)),
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              maxRadius: 30,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(
              title ?? '',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: FittedBox(
                child: Text(
                    'Total: \$${(quantity! * price!).toStringAsFixed(2)}')),
            trailing: Container(
              width: deviceSize.width * 0.3,
              child: FittedBox(
                child: Row(
                  children: [
                    IconButton(
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          Provider.of<Cart>(context, listen: false)
                              .deleteOneItem(productId!);
                        }),
                    Text(
                      '$quantity x',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Provider.of<Cart>(context, listen: false)
                              .addCartItem(productId!, title!, price!);
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
