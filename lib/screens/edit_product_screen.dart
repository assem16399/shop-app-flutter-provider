import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageController = TextEditingController();

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0.0,
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    if (ModalRoute.of(context)!.settings.arguments != null) {
      final id = ModalRoute.of(context)!.settings.arguments as String;

      _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
          .findProductById(id);

      _initValues = {
        'title': _editedProduct.title!,
        'description': _editedProduct.description!,
        'price': _editedProduct.price!.toString(),
        'imageUrl': '',
      };
      _imageController.text = _editedProduct.imageUrl!;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _onFormSubmitted() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      //update the product.....
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id!, _editedProduct);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(error.toString()),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          ),
        );
      }
    } else {
      //create a new product.....
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);

        Navigator.of(context).pop();
      } catch (_) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Something went wrong!'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _onFormSubmitted)
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        hintText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a title!';
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = _editedProduct.copyWith(title: value);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number!';
                        }
                        if (double.parse(value) < 0) {
                          return 'Please enter a number greater than zero!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = _editedProduct.copyWith(
                            price: double.parse(value!));
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        hintText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct =
                            _editedProduct.copyWith(description: value);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: deviceSize.width * 0.25,
                          height: deviceSize.height * 0.14,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: (_imageController.text.isEmpty)
                              ? Text(
                                  'Enter a Url',
                                  textAlign: TextAlign.center,
                                )
                              : Image(
                                  image: NetworkImage(_imageController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageController,
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _onFormSubmitted();
                            },
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Please Enter an Image URL!';
                              if (!value.startsWith('http'))
                                return 'Please Enter a valid URL!';
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct =
                                  _editedProduct.copyWith(imageUrl: value);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                )),
              ),
            ),
    );
  }
}
