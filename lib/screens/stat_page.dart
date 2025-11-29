import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/habit_controller.dart';
import '../models/habit.dart';

class StatPage extends StatefulWidget {
  @override
  State<StatPage> createState() => _MyStatPageState();  
}

class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;
  bool _loading = true;
  final HabitController _habitController = HabitController();
   List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _habitController.getAllHabits();
    setState(() {
      _habits = habits;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7886c7),

        body: Center(
          child: _loading ? const CircularProgressIndicator() 
          : Stack(
            children: <Widget> [ 
              IgnorePointer(
                ignoring: _showStatState,
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 100),
                  itemCount: _habits.length,
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
                          _habits[index].name,
                          style: GoogleFonts.openSans(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_showStatState,
                child: AnimatedOpacity(
                  opacity: !_showStatState ? 0 : 1,
                  duration: Durations.medium1,
                  child: Stack(
                    children: [
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