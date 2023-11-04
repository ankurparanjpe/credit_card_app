import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccumulatedInformation extends StatefulWidget {
  @override
  _AccumulatedInformationState createState() => _AccumulatedInformationState();
}

class _AccumulatedInformationState extends State<AccumulatedInformation> {
  List<Map<String, dynamic>> _creditCardData = [];

  @override
  void initState() {
    super.initState();
    _loadCreditCardData();
  }

  Future<void> _loadCreditCardData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('credit_card_data');

    if (jsonData != null && jsonData.isNotEmpty) {
      final List<dynamic> decodedList = json.decode(jsonData);
      for (var item in decodedList) {
        if (item['totalLimit'] != null) {
          item['totalLimit'] = double.tryParse(item['totalLimit'].toString()) ?? 0.0;
        } else {
          // Handle the case where "totalLimit" is null or empty
          item['totalLimit'] = 0.0;
        }
        if (item['spent'] != null) {
          item['spent'] = double.tryParse(item['spent'].toString()) ?? 0.0;
        } else {
          // Handle the case where "totalLimit" is null or empty
          item['spent'] = 0.0;
        }
      }

      print(decodedList[0]['spent'].runtimeType);
    setState(() {
        _creditCardData = decodedList.map((item) => item as Map<String, dynamic>).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accumulated Information'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: <DataColumn>[
              DataColumn(label: Text('Total cards')),
              DataColumn(label: Text('Total limit')),
              DataColumn(label: Text('Total spent')),
              DataColumn(label: Text('Total remaining')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text(_creditCardData.length.toString())),
                DataCell(Text(_calculateTotalLimit().toStringAsFixed(2))),
                DataCell(Text(_calculateTotalSpent().toStringAsFixed(2))),
                DataCell(Text(_calculateTotalRemaining().toStringAsFixed(2))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalLimit() {
    return _creditCardData.fold(0.0, (sum, cardData) => sum + cardData['totalLimit']);
  }

  double _calculateTotalSpent() {
    return _creditCardData.fold(0.0, (sum, cardData) => sum + cardData['spent']);
  }

  double _calculateTotalRemaining() {
    return _calculateTotalLimit() - _calculateTotalSpent();
  }
}
