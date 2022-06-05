import 'package:flutter/material.dart';
import 'package:pr2_mirror_wall_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mirror Wall 2nd PR',
      home: TeslaScreen(),
    );
  }
}
