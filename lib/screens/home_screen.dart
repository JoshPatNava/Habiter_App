import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller/habit_controller.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();  
}

class _MyHomePageState extends State<MyHomePage> {
  //Controller OBJ
  final HabitController controller = HabitController();

  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showInfoState = false;
  
  //Init for habits and habit logs
  bool _loading = true;
  List<Habit> _habits = [];
  Map<int, Habit> _habitById = {};
  Map<int, int> _completionCountByHabit = {};
  Map<DateTime, List<HabitLog>> _logsByDay = {};
  List<HabitLog> _selectedDayLogs = [];


  @override
  void initState() {
    super.initState();
    loadAll();
  }

  DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> loadAll() async {
    try {
      final habits = await controller.getAllHabits();
      final habitById = <int, Habit>{};
      for(final h in habits) {
        habitById[h.id!] = h;
      }

      final logsByDay = <DateTime, List<HabitLog>>{};
      final completionCountByHabit = <int, int>{};

      for (final habit in habits) {
        final logs = await controller.getHabitLogs(habit.id!);
        completionCountByHabit[habit.id!] = logs.length;

        for (final log in logs) {
          final logDate = dateOnly(log.date);
          logsByDay.putIfAbsent(logDate, () => []).add(log);
        }
      }

      setState(() {
        _habits = habits;
        _habitById = habitById;
        _logsByDay = logsByDay;
        _completionCountByHabit = completionCountByHabit;
        _loading = false;
      });
    } catch(e) {
      setState(() => _loading = false);
    }
  }

List<HabitLog> _getEventsForDay(DateTime day) {
    return _logsByDay[_dateOnly(day)] ?? const [];
  }

  void _handleDaySelect(DateTime selectedDay, DateTime focusedDay) {
    final logs = _getEventsForDay(selectedDay);
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayLogs = logs;
      _showInfoState = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff7886c7),
      body: Center(
        child: Stack(
          children: <Widget> [
            IgnorePointer(
              ignoring: _showInfoState,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 11,
                itemBuilder:(context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TableCalendar(
                          locale: "en_US",
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            headerMargin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                            )
                          ),
                          // Calender 
                          focusedDay: _focusedDay, 
                          firstDay: DateTime.utc(2025, 10, 1), 
                          lastDay: DateTime.utc(today.year + 1, today.month + 1, 1).subtract(const Duration(days: 1)),
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _showInfoState = true;
                            });
                          },
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Container(
                      height: 200,
                      width: 360,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color(0xfffff2f2),
                      ),
                      child: Center(
                        child: Text(
                          "Habit $index Basic Info/Stats\n...\n...",
                          style: GoogleFonts.openSans(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            AnimatedOpacity(
              opacity: _showInfoState ? 1 : 0,
              duration: Durations.medium1,
              child: IgnorePointer(
                ignoring: !_showInfoState,
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
                            _showInfoState = false; 
                            _selectedDay = today;
                            _focusedDay = today;
                            });
                      },
                      child: Center(
                        child: Container(
                          height: 450,
                          width: 300,
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              "Habit Data",
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