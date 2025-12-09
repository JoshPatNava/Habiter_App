import 'package:flutter/material.dart';
import 'package:habiter_app/provider/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _MySettingsPageState();  
}


class _MySettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    int colorOption = Provider.of<ThemeProvider>(context, listen: false).currentThemeSetting;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [ 
            Text(
              "Settings",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: 3,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Icon(Icons.format_paint_rounded),
                  Text(
                    " Appearance",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
            ),
            ListTile(
              title: Text("default"),
              tileColor: Colors.black,
              selectedTileColor: Colors.red,
              selected: colorOption == 0,
              onTap: () {
                print(colorOption);
                setState(() {
                  colorOption = 0;
                });
                Provider.of<ThemeProvider>(context, listen: false).changeTheme(0);
              },
            ),
            ListTile(
              title: Text("dark"),
              tileColor: Colors.white,
              selectedTileColor: Colors.red,
              selected: colorOption == 1,
              onTap: () {
                setState(() {
                  colorOption = 1;
                });
                Provider.of<ThemeProvider>(context, listen: false).changeTheme(1);
              },
            ),
          ]
        ),
      ),
    );
  }
}
