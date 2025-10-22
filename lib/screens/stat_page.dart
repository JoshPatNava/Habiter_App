import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatPage extends StatefulWidget {
  @override
  State<StatPage> createState() => _MyStatPageState();  
}

class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7886c7),
      body: Center(
        child: Stack(
          children: <Widget> [ 
            IgnorePointer(
              ignoring: _showStatState,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: GridView.builder(
                  itemCount: 11,
                  gridDelegate: 
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                  ),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _showStatState = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xfffff2f2),
                      ),
                      child: Center(
                        child: Text(
                          "Habit ${index+1}",
                          style: GoogleFonts.openSans(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            AnimatedOpacity(
              opacity: _showStatState ? 1 : 0,
              duration: Durations.medium1,
              child: IgnorePointer(
                ignoring: !_showStatState,
                child: Stack(
                  children: <Widget> [
                    Opacity(
                      opacity: 0.5,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),

                    TapRegion(
                      onTapOutside:(tap) {
                        setState(() {
                            _showStatState = false; 
                            });
                      },
                      child: Center(
                        child: Container(
                          height: 450,
                          width: 300,
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              "Habit Stats",
                              style: GoogleFonts.openSans(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}