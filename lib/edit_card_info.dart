import 'package:flutter/material.dart';

class EditCreditCardPage extends StatefulWidget {
  final Map<String, dynamic> data;

  EditCreditCardPage({required this.data});

  @override
  _EditCreditCardPageState createState() => _EditCreditCardPageState();
}

class _EditCreditCardPageState extends State<EditCreditCardPage> {
  TextEditingController _cardNameController = TextEditingController();
  TextEditingController _totalLimitController = TextEditingController();
  TextEditingController _billGenerationDateController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the existing data
    _cardNameController.text = widget.data['cardName'];
    _totalLimitController.text = widget.data['totalLimit'].toString();
    _billGenerationDateController.text = widget.data['billGenerationDate'];
    _dueDateController.text = widget.data['dueDate'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Credit Card Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cardNameController,
              decoration: InputDecoration(labelText: 'Credit Card Name'),
            ),
            TextField(
              controller: _totalLimitController,
              decoration: InputDecoration(labelText: 'Total Limit'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _billGenerationDateController,
              decoration: InputDecoration(labelText: 'Bill Generation Date'),
            ),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(labelText: 'Due Date'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the edited data and pop the screen to return to the display page
                final editedData = {
                  'cardName': _cardNameController.text,
                  'totalLimit': double.parse(_totalLimitController.text),
                  'billGenerationDate': _billGenerationDateController.text,
                  'dueDate': _dueDateController.text,
                };

                // You can implement code to save this edited data, e.g., in SharedPreferences
                // and then navigate back to the display page.
                // For simplicity, we're just popping the screen here.
                Navigator.pop(context, editedData);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// class EditCreditCardScreen extends StatefulWidget {
//   final Map<String, dynamic> formData;
//   final Function(Map<String, dynamic>) onSave;
//
//   EditCreditCardScreen({required this.formData, required this.onSave});
//
//   @override
//   _EditCreditCardScreenState createState() => _EditCreditCardScreenState();
// }
//
// class _EditCreditCardScreenState extends State<EditCreditCardScreen> {
//   final _formKey = GlobalKey<FormState>();
//   Map<String, dynamic> _editedData = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _editedData = Map.from(widget.formData);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Credit Card'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16.0),
//           children: [
//             TextFormField(
//               initialValue: _editedData['cardName'].toString(),
//               decoration: InputDecoration(labelText: 'Credit Card Name'),
//               onSaved: (value) {
//                 _editedData['cardName'] = value;
//               },
//             ),
//             TextFormField(
//               initialValue: _editedData['totalLimit'].toString(),
//               decoration: InputDecoration(labelText: 'Total Limit'),
//               onSaved: (value) {
//                 _editedData['totalLimit'] = value;
//               },
//             ),
//             TextFormField(
//               initialValue: _editedData['billGenerationDate'].toString(),
//               decoration: InputDecoration(labelText: 'Bill Generation Date'),
//               onSaved: (value) {
//                 _editedData['billGenerationDate'] = value;
//               },
//             ),
//             TextFormField(
//               initialValue: _editedData['dueDate'].toString(),
//               decoration: InputDecoration(labelText: 'Due Date'),
//               onSaved: (value) {
//                 _editedData['dueDate'] = value;
//               },
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   _formKey.currentState!.save();
//                   widget.onSave(_editedData); // Pass the edited data back to the main screen
//                   Navigator.pop(context); // Close the edit screen
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
