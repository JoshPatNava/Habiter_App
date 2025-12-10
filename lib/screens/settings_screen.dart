import 'package:flutter/material.dart';
import 'package:habiter_app/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(width: 117,
                        height: 100, 
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                      ),
                      Container(width: 117, 
                        height: 100, 
                        color: Color(0xffffeaea),
                        child: Center(
                          child: Text(
                            "Default",
                            style: GoogleFonts.openSans(fontSize: 16, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
                          ),
                        )
                      ),
                      Container(width: 117,
                        height: 100, 
                        decoration: BoxDecoration(
                          color: Color(0xff7886c7),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    minTileHeight: 100,
                    selected: colorOption == 0,
                    onTap: () {
                      setState(() {
                        colorOption = 0;
                      });
                      Provider.of<ThemeProvider>(context, listen: false).changeTheme(0);
                    },
                  ),
                  Visibility(
                    visible: colorOption == 0,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: 351,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: BoxBorder.all(width: 4, color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Align(
                          alignment: Alignment(0.95, -0.8), 
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.outline,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 15),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(width: 117,
                        height: 100, 
                        decoration: BoxDecoration(
                          color: Color(0xff4e388b),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                      ),
                      Container(width: 117, 
                        height: 100, 
                        color: Color(0xff221c27),
                        child: Center(
                          child: Text(
                            "Dark",
                            style: GoogleFonts.openSans(fontSize: 16, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
                          ),
                        )
                      ),
                      Container(width: 117,
                        height: 100, 
                        decoration: BoxDecoration(
                          color: Color(0xff151515),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    minTileHeight: 100,
                    selected: colorOption == 1,
                    onTap: () {
                      setState(() {
                        colorOption = 1;
                      });
                      Provider.of<ThemeProvider>(context, listen: false).changeTheme(1);
                    },
                  ),
                  Visibility(
                    visible: colorOption == 1,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: 351,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: BoxBorder.all(width: 4, color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Align(
                          alignment: Alignment(0.95, -0.8), 
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.outline,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}
