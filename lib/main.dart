import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './helpers/custom-route.dart';
import './providers/auth_provider.dart';
import './providers/cart.dart';
import './providers/orders_provider.dart';
import './providers/products_provider.dart';
import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_details_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/splash_screen.dart';
import 'screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (_) => ProductsProvider([], authToken: null, userId: null),
            update: (context, authData, previousProductsState) =>
                previousProductsState!
                  ..updateUser(authData.tokenGetter, authData.userIdGetter)),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, OrdersProvider>(
            update: (context, authData, previousOrdersState) =>
                previousOrdersState!
                  ..updateUser(authData.tokenGetter, authData.userIdGetter),
            create: (context) => OrdersProvider([], null, null)),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Shop',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(secondary: Colors.deepOrange),
          ),
          home: authData.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  builder: (context, authSnapShot) =>
                      authSnapShot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  future: authData.tryAutoLogin(),
                ),
          routes: {
            ProductsOverviewScreen.routeName: (context) =>
                ProductsOverviewScreen(),
            ProductDetailsScreen.routeName: (context) => ProductDetailsScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
