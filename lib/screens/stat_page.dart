import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class StatPage extends StatefulWidget {
  @override
  State<StatPage> createState() => _MyStatPageState();
}

class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;

  final PanelController _panelController = PanelController();
  TextEditingController _habitName = TextEditingController();
  TextEditingController _habitDesc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7886c7),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        defaultPanelState: PanelState.CLOSED,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        isDraggable: false,
        panel: Center(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  onPressed: () {
                    if (_panelController.isPanelOpen) {
                      _panelController.close();
                    }
                  },
                  icon: const Icon(Icons.close),
                ),
              ),

              ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 40,
                      right: 40,
                    ),
                    child: TextField(
                      controller: _habitName,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        hintText:
                            "Your New Habit Name", // name: _habitName.text
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 40,
                      right: 40,
                    ),
                    child: TextField(
                      controller: _habitDesc,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        hintText: "Description...", // name: _habitDesc.text
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Center(
          child: Stack(
            children: <Widget>[
              IgnorePointer(
                ignoring: _showStatState,
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 20,
                    right: 20,
                    bottom: 100,
                  ),
                  itemCount: 11,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          "Habit ${index + 1}",
                          style: GoogleFonts.openSans(fontSize: 30),
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
                    children: <Widget>[
                      Opacity(
                        opacity: 0.5,
                        child: Container(color: Colors.black),
                      ),

                      TapRegion(
                        onTapOutside: (tap) {
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
                                style: GoogleFonts.openSans(fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: !_panelController.isPanelOpen ? 1 : 0,
        duration: Durations.medium1,
        child: IgnorePointer(
          ignoring: _showStatState,
          child: FloatingActionButton(
            onPressed: () {
              if (!_panelController.isPanelOpen) {
                _panelController.open();
              }
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
