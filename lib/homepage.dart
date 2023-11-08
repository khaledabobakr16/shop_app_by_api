import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shop_app_by_api/data/categories.dart';
import 'package:shop_app_by_api/models/grocery_item.dart';

import 'widgets/grocery_list.dart';
import 'widgets/new_item.dart';
import 'models/category.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GroceryItem> groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    final url = Uri.https(
        'shop-app-by-api-default-rtdb.firebaseio.com', 'shopping_list.json');
    final http.Response res = await http.get(url);
    log(res.body.toString());
    if (res.statusCode >= 400) {
      setState(() {
        _error = "Faild to fetch data.";
      });
    }
    if (json.decode(res.body) == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> loadedData = json.decode(res.body);
    final List<GroceryItem> loadedItems = [];
    for (var item in loadedData.entries) {
      final Category category = categories.entries
          .firstWhere(
            (element) => element.value.title == item.value['category'],
          )
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
      setState(() {
        groceryItems = loadedItems;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No item added."),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (groceryItems.isNotEmpty) {
      content = CroceryList(groceryItems: groceryItems);
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Grocery"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (ctx) => const NewItem(),
    ));
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
      _isLoading = false;
    });
  }
}
