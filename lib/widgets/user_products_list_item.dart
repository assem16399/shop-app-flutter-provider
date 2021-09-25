import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';

class UserProductsListItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;
  UserProductsListItem(
      {required this.id, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            title,
            softWrap: true,
            maxLines: 1,
            textWidthBasis: TextWidthBasis.parent,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20),
          ),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          trailing: Container(
            width: deviceSize.width * 0.245,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  color: Theme.of(context).colorScheme.primary,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  onPressed: () async {
                    try {
                      await Provider.of<ProductsProvider>(context,
                              listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    }
                  },
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
