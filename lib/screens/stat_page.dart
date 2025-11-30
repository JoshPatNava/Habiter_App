import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/habit_controller.dart';
import '../models/habit.dart';

class StatPage extends StatefulWidget {
  const StatPage({Key? key}) : super(key: key);

  @override
  State<StatPage> createState() => _MyStatPageState();  
}


class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;
  bool _loading = true;
  final HabitController _habitController = HabitController();
  List<Habit> _habits = [];
  Habit? _selectedHabit;
  int? _totalCompletions;
  int? _currentStreak;
  int? _bestStreak;
  bool _loadingStats = false;
  double? _completionRate;
  int? _weeklyGoal;
  int? _weeklyProgress;
  double? _weeklyPercentage;



  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _habitController.getAllHabits();
    setState(() {
      _habits = habits;
      _loading = false;
    });
  }
    
  Future<void> _loadHabitStats(Habit habit) async {
   setState(() {
      _loadingStats = true;
      _selectedHabit = habit;
   });

    _totalCompletions =
        await _habitController.getTotalCompletions(habit.id!);
    _currentStreak =
        await _habitController.getCurrentStreak(habit.id!);
    _bestStreak =
        await _habitController.getBestStreak(habit.id!);
    _completionRate = 
        await _habitController.getCompletionRate(habit);
    if (habit.frequency == 2) {
     final goal = await _habitController.getWeeklyGoalProgress(habit);

     _weeklyGoal = goal["goal"];
     _weeklyProgress = goal["progress"];
      _weeklyPercentage = goal["percentage"];
    } else {
      _weeklyGoal = null;
      _weeklyProgress = null;
      _weeklyPercentage = null;
  }

    setState(() {
      _loadingStats = false;
    });
  }

  @override
  void didUpdateWidget(covariant StatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadHabits(); 
    _showStatState = false;
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
                      _loadHabitStats(_habits[index]);
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

                      SizedBox.expand(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _showStatState = false;
                                });
                              },

                            
                              child: Center(
                                child: Container(
                                  height: 450,
                                  width: 300,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: _loadingStats
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator())
                                      : SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // TITLE
                                              Text(
                                                _selectedHabit?.name ??
                                                    "",
                                                style:
                                                    GoogleFonts.openSans(
                                                  fontSize: 28,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),

                                              _buildStatRow(
                                                "Total completions:",
                                                _totalCompletions,
                                              ),
                                              const SizedBox(height: 10),

                                              _buildStatRow(
                                                "Current streak:",
                                                _currentStreak,
                                              ),
                                              const SizedBox(height: 10),

                                              _buildStatRow(
                                                "Best streak:",
                                                _bestStreak,
                                              ),
                                              const SizedBox(height: 10),

                                              _buildStatRowString(
                                                "Completion rate:",
                                                _completionRate == null
                                                    ? "--"
                                                    : "${(_completionRate! * 100).toStringAsFixed(1)}%",
                                              ),
                                              const SizedBox(height: 20),

                                              if (_selectedHabit
                                                      ?.frequency ==
                                                  2) ...[
                                                Text(
                                                  "Weekly Goals",
                                                  style: GoogleFonts
                                                      .openSans(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),

                                                _buildStatRow(
                                                    "Weekly goal:",
                                                    _weeklyGoal),
                                                const SizedBox(height: 10),

                                                _buildStatRow("Progress:",
                                                    _weeklyProgress),
                                                const SizedBox(height: 10),

                                                _buildStatRowString(
                                                  "Goal progress:",
                                                  _weeklyPercentage ==
                                                          null
                                                      ? "--"
                                                      : "${(_weeklyPercentage! * 100).toStringAsFixed(1)}%",
                                                ),
                                                const SizedBox(height: 20),
                                              ],

                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _showStatState =
                                                          false;
                                                    });
                                                  },
                                                  child: const Text("Close"),
                                                ),
                                              ),

                                              const SizedBox(height: 20),
                                            ],
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
                ],
              ),
      ),
    );
  }
  Widget _buildStatRowString(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(fontSize: 16),
        ),
        Text(
          value,
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _buildStatRow(String label, int? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(fontSize: 16),
        ),
        Text(
          value?.toString() ?? "--",
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}