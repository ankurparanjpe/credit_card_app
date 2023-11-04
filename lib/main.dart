import 'package:flutter/material.dart';
import 'credit_card_form.dart';
import 'display_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DisplayPage(),
      routes: {
        '/display': (context) => DisplayPage()
      },
    );
  }
}