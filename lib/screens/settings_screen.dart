import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _MySettingsPageState();  
}

class _MySettingsPageState extends State<SettingsPage> {
  bool _showSettingsState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7886c7),
      body: Center(
        child: Stack(
          children: <Widget> [ 
            IgnorePointer(
              ignoring: _showSettingsState,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                
              ),
            ),
          ]
        ),
      ),
    );
  }
}