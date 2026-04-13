import 'package:flutter/material.dart';
import 'screens/rolodex_screen.dart';

void main() => runApp(const RolodexApp());

class RolodexApp extends StatelessWidget {
  const RolodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rolodex',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const RolodexScreen(),
    );
  }
}