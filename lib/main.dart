import 'package:flutter/material.dart';
import 'package:u3_ejercicio2_tablasconforanea/programa.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.light(scheme: FlexScheme.sakura),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.sakura),
      themeMode: ThemeMode.light,
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
