import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditCardForm extends StatefulWidget {
  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _prefsKey = 'credit_card_data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'cardName',
                decoration: InputDecoration(labelText: 'Credit Card Name'),
              ),
              FormBuilderTextField(
                name: 'totalLimit',
                decoration: InputDecoration(labelText: 'Total Limit'),
                keyboardType: TextInputType.number,
              ),
              FormBuilderTextField(
                name: 'billGenerationDate',
                decoration: InputDecoration(labelText: 'Bill Generation Date'),
                keyboardType: TextInputType.number,
              ),
              FormBuilderTextField(
                name: 'dueDate',
                decoration: InputDecoration(labelText: 'Due Date'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    // final prefs = await SharedPreferences.getInstance();
                    // await prefs.clear();
                    final formData = _formKey.currentState?.value;
                    await saveToLocalStorage(formData);
                    Navigator.pushNamed(context, '/display'); // Navigate to the DisplayPage
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> saveToLocalStorage(Map<String, dynamic>? formData) async {
    if (formData != null) {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> formDataList = [];

      // Retrieve existing data and convert it to a list of maps
      String? jsonData = prefs.getString(_prefsKey);
      if (jsonData != null && jsonData.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(jsonData);
        print('Decoded list: $decodedList');
        formDataList.addAll(decodedList.map((item) => item as Map<String, dynamic>).toList());
        print('formDataList after addition: $formDataList');
        print('formDataList after addition: $formData');
        print(formData.runtimeType);
      }
      // Add the new form data
      formDataList.add(formData);
      // Save the updated data as a JSON string
      await prefs.setString(_prefsKey, json.encode(formDataList));
      final savedData = prefs.getString('cardData');
      print("downwards");
      print(formDataList);
    }
  }

}
