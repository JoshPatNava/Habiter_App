import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/habit_tile.dart';
import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';
import 'db/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}