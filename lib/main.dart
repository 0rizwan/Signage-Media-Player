import 'package:flutter/material.dart';
import 'package:signage_media_player/screens/signage_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignageScreen(),
    );
  }
}

