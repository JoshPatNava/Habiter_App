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
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Habiter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [Text('A random idea:'), Text(appState.current.asLowerCase)],
      ),
    );
  }
}