import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/habit_controller.dart';
import '../models/habit.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

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
  DateTime now = DateTime.now();



  @override
  void initState() {
    super.initState();
      _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _habitController.getAllHabits();

    if (!mounted) return;

    setState(() {
      _habits = habits;
      _loading = false;
    });
  }
    
 Future<void> _loadHabitStats(Habit habit) async {
  if (!mounted) return;

  setState(() {
    _loadingStats = true;
    _selectedHabit = habit;
    _totalCompletions = null;
    _currentStreak = null;
    _bestStreak = null;
    _completionRate = null;
    _weeklyGoal = null;
    _weeklyProgress = null;
    _weeklyPercentage = null;
    _last7Days = List<bool>.filled(7, false);
    _lifetimeStats = {};
  });

  try {
    final results = await Future.wait([
      _habitController.getTotalCompletions(habit.id!),
      _habitController.getCurrentStreak(habit.id!),
      _habitController.getBestStreak(habit.id!),
      _habitController.getLast7DaysCompletion(habit.id!),
      _habitController.getCompletionRate(habit),
      getLifetimeStats(),
      if (habit.frequency == 2)
        _habitController.getWeeklyGoalProgress(habit)
    ]);

    int idx = 0;
    final totalCompletions = results[idx++] as int;
    final currentStreak = results[idx++] as int;
    final bestStreak = results[idx++] as int;
    final last7Days = results[idx++] as List<bool>;
    final completionRate = results[idx++] as double;
    final lifetimeStats = results[idx++] as Map<String, String>;

    int? weeklyGoal;
    int? weeklyProgress;
    double? weeklyPercentage;

    if (habit.frequency == 2) {
      final goal = results[idx] as Map<String, dynamic>;
      weeklyGoal = goal["goal"];
      weeklyProgress = goal["progress"];
      weeklyPercentage = goal["percentage"];
    }

    if (!mounted) return;

    setState(() {
      _totalCompletions = totalCompletions;
      _currentStreak = currentStreak;
      _bestStreak = bestStreak;
      _last7Days = last7Days;
      _completionRate = completionRate;
      _lifetimeStats = lifetimeStats;
      _weeklyGoal = weeklyGoal;
      _weeklyProgress = weeklyProgress;
      _weeklyPercentage = weeklyPercentage;
      _loadingStats = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() => _loadingStats = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading stats: $e")));
  }
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
  int habitAgeDays = now.difference(start).inDays + 1;

  final logs = await _habitController.getAllLogsForHabit(_selectedHabit!.id!);
  final completedLogs = logs.where((l) => l.completed).toList();

  if (completedLogs.isEmpty) {
    return {
      "Habit age": "$habitAgeDays days",
      "First completion": "No completions yet",
      "Last completion": "No completions yet",
      "Days tracked": "$habitAgeDays days",
    };
  }
  
  completedLogs.sort(
    (a, b) => parseDate(a.date).compareTo(parseDate(b.date)),
  );


  final firstDate = parseDate(completedLogs.first.date.trim());
  final lastDate = parseDate(completedLogs.last.date.trim());

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

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
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      child: Center(
                        child: Text(
                          _habits[index].name,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
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
                                    color: Theme.of(context).colorScheme.surfaceContainer,
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
                                                    Theme.of(context).textTheme.headlineMedium!.copyWith(
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

                                              Text(
                                                  "Last 7 Days",
                                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                ),
                                                ),
                                                const SizedBox(height: 10),

                                                _build7DayChart(),

                                                const SizedBox(height: 20),   
                                             

                                              if (_selectedHabit
                                                      ?.frequency ==
                                                  2) ...[
                                                Text(
                                                  "Weekly Goals",
                                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                    fontWeight: 
                                                        FontWeight.bold,
                                                ),
                                                ),
                                                const SizedBox(height: 10),

                                                SizedBox(height: 20),

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
                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),

                                              Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: _lifetimeStats.entries.map((entry) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(entry.key,
                                                        style: Theme.of(context).textTheme.titleMedium,
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(entry.value,
                                                        style: Theme.of(context).textTheme.titleMedium,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                              Text(
                                                "Achievements",
                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                                                    style: Theme.of(context).textTheme.titleMedium,
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
                                                  child: Text(
                                                    "Close",
                                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                                  ),
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

  DateTime parseDate(String date) {
  final p = date.split('-');
  return DateTime(
    int.parse(p[0]), 
    int.parse(p[1]), 
    int.parse(p[2]), 
  );
}

  Widget _buildStatRowString(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value?.toString() ?? "--",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _build7DayChart() {
  final labels = [
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 6))), 
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 5))),
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 4))),
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 3))),
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 2))),
    DateFormat('MMM\n d').format(now.subtract(const Duration(days: 1))), 
    DateFormat('MMM\n d').format(now),
  ];

  final data = _last7Days.length == 7
      ? _last7Days
      : List<bool>.filled(7, false);


  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(7, (i) {
      final done = data[i];

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
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }),
  );
}
}