import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habiter_app/provider/theme.dart';
import 'package:habiter_app/screens/stat_page.dart';
import 'package:habiter_app/screens/home_screen.dart';
import 'package:habiter_app/screens/settings_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp( 
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: MainScreen(),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
    super.initState();
  }

  int _selectedIndex = 1;

List<Widget> get _screens => [
  StatPage(key: UniqueKey()),
  MyHomePage(key: UniqueKey()),
  SettingsPage(key: UniqueKey()),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5.0,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.list_alt_outlined),
                onPressed: () {
                  setState(() {_selectedIndex = 0;});
                },
              ),
              IconButton(
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.home),
                onPressed: () {
                  setState(() {_selectedIndex = 1;});
                },
              ),
              IconButton(
                iconSize: 50,
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.settings),
                onPressed: () {
                  setState(() {_selectedIndex = 2;});
                },
              )
            ],
          ),
        ),
      ),
    );
  }


}
