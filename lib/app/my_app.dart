import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final Widget home;
  final String title;

  const MyApp({super.key, required this.home, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: home,
    );
  }
}
