import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

class CroceryList extends StatefulWidget {
  const CroceryList({super.key, required this.groceryItems});
  final List<GroceryItem> groceryItems;

  @override
  State<CroceryList> createState() => _CroceryListState();
}

class _CroceryListState extends State<CroceryList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.groceryItems.length,
        itemBuilder: (c, index) => Dismissible(
              key: ValueKey(widget.groceryItems[index].id),
              onDismissed: (_) {
                _deleteItem(widget.groceryItems[index]);
              },
              child: ListTile(
                title: Text(widget.groceryItems[index].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: widget.groceryItems[index].category.color,
                ),
                trailing:
                    Text((widget.groceryItems[index].quantity.toString())),
              ),
            ));
  }

  void _deleteItem(GroceryItem item) async {
    final index = widget.groceryItems.indexOf(item);
    setState(() {
      widget.groceryItems.remove(item);
    });

    final url = Uri.https('shop-app-by-api-default-rtdb.firebaseio.com',
        'shopping_list/${item.id}.json');

    final res = await http.delete(url);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Deleted successflly.")));
    if (res.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Not delete the item,Please try again.")));
      setState(() {
        widget.groceryItems.insert(index, item);
      });
    }
  }
}
