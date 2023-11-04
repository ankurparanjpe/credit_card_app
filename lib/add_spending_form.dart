import 'package:flutter/material.dart';

class AddSpendingForm extends StatefulWidget {
  final List<String> creditCardNames;
  final Function(String cardName, double spentAmount) onSubmit;

  AddSpendingForm({
    required this.creditCardNames,
    required this.onSubmit,
  });

  @override
  _AddSpendingFormState createState() => _AddSpendingFormState();
}

class _AddSpendingFormState extends State<AddSpendingForm> {
  int selectedCardIndex = 0; // Initially select the first item
  double spentAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Spending'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<int>(
              value: selectedCardIndex,
              items: widget.creditCardNames.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key, // Use the index as the value (an integer)
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCardIndex = value!;
                });
              },
              hint: Text('Select a credit card'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Spent Amount'),
              onChanged: (value) {
                setState(() {
                  spentAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                String selectedCardName = widget.creditCardNames[selectedCardIndex];
                widget.onSubmit(selectedCardName, spentAmount);
                Navigator.pop(context);
              },
              child: Text('Add Spending'),
            ),
          ],
        ),
      ),
    );
  }
}
