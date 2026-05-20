import 'package:flutter/material.dart';


class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  // Define a list of items for the dropdown menu
  final List<String> _items = [
    'Food', 'Health', 'Education', 'Bills',
    'Transport', 'Shopping', 'Maintenance', 'Household',
    'Pets', 'Sports', 'Entertainment', 'Gifts',
    'Vacations', 'Restaurant ', 'Others',
  ];

  // Define a variable to hold the selected item
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          hint: const Text('Select Category'),
          value: _selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              _selectedItem = newValue;
            });
          },
          items: _items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}