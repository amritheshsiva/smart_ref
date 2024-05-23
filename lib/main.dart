import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

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
  bool _isLoading = false;
  bool _showNumberOfItems = false; // Add this variable

  void _calculateNumberOfItems() async {
    double itemWeight = double.tryParse(_itemWeightController.text) ?? 0;

    if (itemWeight == 0) {
      setState(() {
        _showNumberOfItems = false;
        _numberOfItems = 0;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
      log('API Error: $error');
    }

    if (itemWeight != 0 && _totalWeight != 0) {
      setState(() {
        _numberOfItems = _totalWeight / itemWeight;
        _showNumberOfItems = true; // Show the number of items
      });
    } else {
      setState(() {
        _numberOfItems = 0;
        _showNumberOfItems = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _itemWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Weight of Single Item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateNumberOfItems,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showNumberOfItems
                ? Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Number of Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _numberOfItems.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(), // Hide the number of items card
          ],
        ),
      ),
    );
  }
}
