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
  List<bool> _last7Days = [];
  Map<String, String> _lifetimeStats = {};



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
    _last7Days =
        await _habitController.getLast7DaysCompletion(habit.id!);
    _completionRate = 
        await _habitController.getCompletionRate(habit);
    _lifetimeStats =
        await getLifetimeStats();

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

  List<String> _getAchievements() {
  List<String> achievements = [];

  if ((_bestStreak ?? 0) >= 3) achievements.add("🏆 3-Day Streak");
  if ((_bestStreak ?? 0) >= 7) achievements.add("🏆 7-Day Streak");
  if ((_bestStreak ?? 0) >= 14) achievements.add("🏆 14-Day Streak");

  if ((_totalCompletions ?? 0) >= 50) achievements.add("💪 50 Completions");
  if ((_totalCompletions ?? 0) >= 100) achievements.add("🐱 100 Completions");

  if (_selectedHabit?.frequency == 2) {
    if (_weeklyGoal != null &&
        _weeklyProgress != null &&
        _weeklyProgress == _weeklyGoal &&
        _weeklyGoal! > 0) {
      achievements.add("⭐️ Perfect Week");
    }
  }
  if (achievements.isEmpty) {
    achievements.add("No achievements yet");
  }

  return achievements;
}

Future<Map<String, String>> getLifetimeStats() async {
  if (_selectedHabit == null) {
    return {};
  }

  DateTime start = _selectedHabit!.startDate;
  DateTime now = DateTime.now();
  int habitAgeDays = now.difference(start).inDays + 1;

  final logs = await _habitController.getAllLogsForHabit(_selectedHabit!.id!);
  final completedLogs = logs.where((l) => l.completed).toList();

  if (_totalCompletions == null || _totalCompletions == 0) {
    return {
      "Habit age": "$habitAgeDays days",
      "First completion": "No completions yet",
      "Last completion": "No completions yet",
      "Days tracked": "$habitAgeDays days",
    };
  }

  completedLogs.sort((a, b) => a.date.compareTo(b.date));

  final firstDate = DateTime.parse(completedLogs.first.date);
  final lastDate = DateTime.parse(completedLogs.last.date);

  String format(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  return {
    "Habit age": "$habitAgeDays days",
    "First completion": format(firstDate),
    "Last completion": format(lastDate),
    "Days tracked": "$habitAgeDays days",
  };
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

                                                SizedBox(height: 20),

                                                Text(
                                                  "Last 7 Days",
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                                ),
                                                const SizedBox(height: 10),

                                                _build7DayChart(),

                                                const SizedBox(height: 20),   

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
                                              SizedBox(height: 20),
                                              Text(
                                                "Lifetime Stats",
                                                style: GoogleFonts.openSans(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: _lifetimeStats.entries.map((entry) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(entry.key,
                                                        style: GoogleFonts.openSans(fontSize: 16)),
                                                      Text(entry.value,
                                                        style: GoogleFonts.openSans(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        )),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                              Text(
                                                "Achievements",
                                                style: GoogleFonts.openSans(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: _getAchievements().map((a) {
                                                  return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Text(
                                                    a,
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                            SizedBox(height: 20),

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

  Widget _build7DayChart() {
  final labels = ["S", "M", "T", "W", "T", "F", "S"];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(7, (i) {
      final done = _last7Days[i];

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: done ? 40 : 10,
            width: 12,
            decoration: BoxDecoration(
              color: done ? Colors.green : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 6),
          Text(
            labels[i],
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }),
  );
}
}