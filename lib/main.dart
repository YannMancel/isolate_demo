import 'package:flutter/material.dart';
import 'package:isolate_demo/_features.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(title: 'Isolate'),
    );
  }
}
