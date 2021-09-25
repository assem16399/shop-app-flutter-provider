import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/cart.dart';
import '../providers/orders_provider.dart';

class OrdersListItem extends StatefulWidget {
  final Order order;

  OrdersListItem(this.order);

  @override
  _OrdersListItemState createState() => _OrdersListItemState();
}

class _OrdersListItemState extends State<OrdersListItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.totalAmount}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon((_expanded) ? Icons.expand_less : Icons.expand_more),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            height: _expanded
                ? min(widget.order.products.length * 20 + 10,
                    deviceSize.height * 0.2)
                : 0,
            child: ListView.builder(
                itemCount: widget.order.products.length,
                itemBuilder: (context, index) => Expandable(
                      order: widget.order.products[index],
                    )),
          )
        ],
      ),
    );
  }
}

class Expandable extends StatelessWidget {
  const Expandable({
    Key? key,
    required this.order,
  }) : super(key: key);

  final CartItem order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.title!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${order.quantity}x \$${order.price}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
