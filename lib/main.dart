import 'package:flutter/material.dart';
import 'screens/tela_home.dart';

void main() {
  runApp(const PratoCertoApp());
}

class PratoCertoApp extends StatelessWidget {
  const PratoCertoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prato Certo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TelaHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}