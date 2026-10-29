import 'package:flutter/material.dart';

void main() => runApp(const CalendarApp());

/// The Malayalam Calendar app.
class CalendarApp extends StatelessWidget {
  /// Creates the app.
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Malayalam Calendar',
        home: Scaffold(body: Center(child: Text('Malayalam Calendar'))),
      );
}
