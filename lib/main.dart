import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/screens/stat_page.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'db/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  int _selectedIndex = 1;

  final List<Widget> _screens = [StatPage(), MyHomePage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffffdada),
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.list_alt_outlined),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.home),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.settings),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
