import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItemCalculatorPage(),
    );
  }
}

class ItemCalculatorPage extends StatefulWidget {
  @override
  _ItemCalculatorPageState createState() => _ItemCalculatorPageState();
}

class _ItemCalculatorPageState extends State<ItemCalculatorPage> {
  final TextEditingController _itemWeightController = TextEditingController();
  double _numberOfItems = 0;
  double _totalWeight = 0;

  void _calculateNumberOfItems() async {
    double itemWeight = double.tryParse(_itemWeightController.text) ?? 0;

    try {
      final response =
          await http.get(Uri.parse('https://smartrefapi.onrender.com/data'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _totalWeight = responseData['weight'];
        });
      } else {
        throw Exception('Failed to load total weight');
      }
    } catch (error) {
      print('Error: $error');
    }

    if (itemWeight != 0 && _totalWeight != 0) {
      setState(() {
        _numberOfItems = (_totalWeight / itemWeight);
      });
    } else {
      setState(() {
        _numberOfItems = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _itemWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Weight of Single Item',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateNumberOfItems,
              child: Text('Calculate'),
            ),
            SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      _numberOfItems.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
