import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shop_app_by_api/data/categories.dart';
import 'package:shop_app_by_api/models/category.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var name = '';
  int quantity = 0;
  var selectedCategory = categories[Categories.fruit]!;
  bool _isLoading = false;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final url = Uri.https(
          'shop-app-by-api-default-rtdb.firebaseio.com', 'shopping_list.json');
      http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': name,
            'quantity': quantity,
            'category': selectedCategory.title
          },
        ),
      )
          .then((res) {
        final Map<String, dynamic> resData = json.decode(res.body);
        log(res.body);
        log(res.statusCode.toString());
        if (res.statusCode == 200) {
          Navigator.of(context).pop(
            GroceryItem(
              id: resData['name'],
              name: name,
              quantity: quantity,
              category: selectedCategory,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  maxLength: 50,
                  onSaved: (newValue) {
                    name = newValue!;
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 chracters';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) {
                          quantity = int.parse(newValue!);
                        },
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                        initialValue: '1',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ]),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: const Text('Reset')),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator())
                          : const Text("Add Item"),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
