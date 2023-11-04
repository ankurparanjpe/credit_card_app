// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'accumulated_info_screen.dart';
import 'credit_card_form.dart';
import 'edit_card_info.dart';
import 'add_spending_form.dart';
import 'package:intl/intl.dart';

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  final _prefsKey = 'credit_card_data';

  List<Map<String, dynamic>> _creditCardData = [];

  @override
  void initState() {
    super.initState();
    _loadCreditCardData();
  }

  List<String> removeDuplicates(List<String> cardNames) {
    // Use a Set to automatically remove duplicates
    Set<String> uniqueCardNames = Set<String>.from(cardNames);
    return uniqueCardNames.toList();
  }

  List<String> _getCreditCardNames() {
    List<String> cardNames = _creditCardData.map((data) => data['cardName'] as String).toList();
    List<String> uniqueCardNames = removeDuplicates(cardNames);
    return uniqueCardNames;
  }


  void _addSpending(String cardName, double spentAmount) async {
    // Find the credit card data to update
    for (var cardData in _creditCardData) {
      if (cardData['cardName'] == cardName) {
        // Update the 'spent' value
        cardData['spent'] = cardData['spent'] != null ? cardData['spent'] + spentAmount : spentAmount;

        // Recalculate the remaining limit
        print("cardData['totalLimit'] and cardData['spent']");
        print(cardData['totalLimit'].runtimeType);
        print(cardData['spent'].runtimeType);
        cardData['remaining'] = double.parse(cardData['totalLimit']) - cardData['spent'];

        // Save the updated data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, json.encode(_creditCardData));
        break; // Exit the loop once the data is updated
      }
    }

    // Navigate back to the DisplayPage and replace the current route
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPage(),
      ),
    );
  }




  Future<void> _loadCreditCardData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(_prefsKey);

    if (jsonData != null && jsonData.isNotEmpty) {
      final List<dynamic> decodedList = json.decode(jsonData);

      final currentDate = DateTime.now();
      for (var cardData in decodedList) {
        final int dueDate = int.parse(cardData['dueDate']);
        final int billGenerationDate = int.parse(cardData['billGenerationDate']);
        DateTime nextMonth;
        if (currentDate.day > billGenerationDate) {
          nextMonth = DateTime(currentDate.year, currentDate.month + 1, billGenerationDate);
        } else {
          nextMonth = DateTime(currentDate.year, currentDate.month, billGenerationDate);
        }
        if (nextMonth.day > dueDate) {
          nextMonth = DateTime(nextMonth.year, nextMonth.month + 1, dueDate);
        } else {
          nextMonth = DateTime(nextMonth.year, nextMonth.month, dueDate);
        }
        // print("nextMonth");
        // DateTime abc = DateTime(2023, 12, 4);
        String formattedDate = DateFormat('d MMM').format(nextMonth);
        // print(formattedDate);
        final daysUntilDue = nextMonth.difference(currentDate).inDays;
        cardData['days_until_due'] = daysUntilDue;
        cardData['formattedDate'] = formattedDate;
        // Apply the condition to set 'spent' to 0 if it's null, 0, or an empty string
        if (cardData['spent'] == null || cardData['spent'] == 0 || cardData['spent'] == '') {
          cardData['spent'] = 0.0;
        }

        if (cardData['remaining'] == null || cardData['remaining'] == 0 || cardData['remaining'] == '') {
          cardData['remaining'] = double.parse(cardData['totalLimit']);
        }
        // Save the updated data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? jsonData = prefs.getString(_prefsKey);

        if (jsonData != null && jsonData.isNotEmpty) {
          final List<dynamic> decodedList = json.decode(jsonData);
          // Update the corresponding cardData in the list
          for (var data in decodedList) {
            if (data['cardName'] == cardData['cardName']) {
              data['spent'] = cardData['spent'];
              data['remaining'] = cardData['remaining'];
              // You can also update other fields as needed
            }
          }
          // Save the updated list back to SharedPreferences
          await prefs.setString(_prefsKey, json.encode(decodedList));
        }




        print(cardData);
      }

      print(decodedList);
      decodedList.sort((a, b) {
        int daysUntilDueA = a['days_until_due'];
        int daysUntilDueB = b['days_until_due'];
        return daysUntilDueB.compareTo(daysUntilDueA);
      });

      setState(() {
        _creditCardData = decodedList.map((item) => item as Map<String, dynamic>).toList();
      });
    }
  }

  void _deleteCard(int index) async {
    // Remove the card at the specified index
    setState(() {
      _creditCardData.removeAt(index);
    });

    // Save the updated list to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString(_prefsKey, json.encode(_creditCardData));
  }

  void _editCard(int index) async {
    final editedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCreditCardPage(data: _creditCardData[index]),
      ),
    );

    if (editedData != null) {
      setState(() {
        _creditCardData[index] = editedData;
      });

      // Save the updated list to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, json.encode(_creditCardData));
      await _loadCreditCardData();
    }
  }

  String _sortOption = 'Sort by Due date';

  // Sort by due date in descending order
  void sortByDueDate() {
    _creditCardData.sort((a, b) {
      int daysUntilDueA = a['days_until_due'];
      int daysUntilDueB = b['days_until_due'];
      return daysUntilDueB.compareTo(daysUntilDueA);
    });
    setState(() {});
  }

  // Sort by spent amount in descending order
  void sortBySpentAmount() {
    _creditCardData.sort((a, b) {
      double spentA = double.tryParse(a['remaining'].toString()) ?? 0.0;
      double spentB = double.tryParse(b['remaining'].toString()) ?? 0.0;
      return spentB.compareTo(spentA);
    });
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card Information'),
        actions: [
          // Add a button to navigate to the form page
          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => CreditCardForm(), // Navigate to your form page
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => AddSpendingForm(creditCardNames: _getCreditCardNames(), onSubmit: _addSpending),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: DropdownButton<String?>(
                  value: _sortOption,
                  items: <String?>[
                    'Sort by Due date',
                    'Sort by remaining limit',
                  ].map((String? value) {
                    return DropdownMenuItem<String?>(
                      value: value,
                      child: Text(value ?? ''), // Handle null value if necessary
                    );
                  }).toList(),
                  onChanged: (String? newValue) { // Change the parameter type to String?
                    setState(() {
                      _sortOption = newValue ?? ''; // Handle null value if necessary
                      if (newValue == 'Sort by Due date') {
                        sortByDueDate();
                      } else if (newValue == 'Sort by remaining limit') {
                        sortBySpentAmount();
                      }
                    });
                  },
                ),
              ),
              DataTable(
                columns: <DataColumn>[
                  DataColumn(label: Text('Credit Card Name')),
                  DataColumn(label: Text('Days to utilize')),
                  DataColumn(label: Text('Total Limit')),
                  DataColumn(label: Text('Spent')),
                  DataColumn(label: Text('Remaining limit')),
                  DataColumn(label: Text('Bill Generation Date')),

                  DataColumn(label: Text('Actions')), // Add a column for the delete button
                ],
                rows: _creditCardData.asMap().entries.map((cardData) {
                  final index = cardData.key;
                  final data = cardData.value;
                  return DataRow(cells: [
                    DataCell(Text(data['cardName'])),
                    DataCell(Text(data['days_until_due'].toString() + ' (' + data['formattedDate'].toString() + ')')),
                    DataCell(Text(data['totalLimit'].toString())),
                    DataCell(Text(data['spent'].toString())),
                    DataCell(Text(data['remaining'].toString())),
                    DataCell(Text(data['billGenerationDate'])),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editCard(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteCard(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccumulatedInformation(),
                      ),
                    );
                  },
                  child: Text('View Accumulated Information'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreditCardForm(),
                      ),
                    );
                  },
                  child: Text('Add credit card'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSpendingForm(creditCardNames: _getCreditCardNames(), onSubmit: _addSpending),
                      ),
                    );
                  },
                  child: Text('Add expenditure'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
