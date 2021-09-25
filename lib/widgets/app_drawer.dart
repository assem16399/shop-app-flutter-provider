import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/custom-route.dart';
import '../providers/auth_provider.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Aloha There!',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryTextTheme.headline6!.color,
                  fontStyle: FontStyle.italic),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: ListTile(
              leading: Icon(Icons.shop),
              title: Text(
                'Products',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(OrdersScreen.routeName);
              Navigator.of(context).pushReplacement(
                  CustomRoute(builder: (context) => OrdersScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.delivery_dining),
              title: Text(
                'Orders',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Manage Products',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
