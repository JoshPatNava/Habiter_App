import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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

  DateTime _today = DateTime.now();
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
  bool _completedOnly = true;


  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _loadAll() async {
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
          final logDate = _dateOnly(DateTime.parse(log.date));
          logsByDay.putIfAbsent(logDate, () => <HabitLog>[]).add(log);
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
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

List<HabitLog> _getEventsForDay(DateTime day) {
    return _logsByDay[_dateOnly(day)] ?? const <HabitLog>[];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final logs = _getEventsForDay(selectedDay);
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayLogs = logs;
      _showInfoState = true;
    });
  }

  void _confirmDeleteHabit(Habit habit) {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Habit"),
          content: Text("Are you sure you want to delete the habit \"${habit.name}\"? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await controller.deleteHabit(habit.id!);
                await _loadAll(); // Refresh data
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      }
    );
  }

  void _showEditHabitDialog(Habit habit) {
    final TextEditingController nameCtrl =
        TextEditingController(text: habit.name);
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Edit Habit"),
          content: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: "Habit name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  final updated = habit.copyWith(name: newName);
                  await controller.updateHabit(updated);
                  await _loadAll();
                }
                Navigator.pop(dialogContext);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeHabitToday(Habit habit) async {
  final newLog = HabitLog(
    habitId: habit.id!,
    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    completed: true,
  );

  await controller.addHabitLog(newLog);
  await _loadAll(); 
}

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    backgroundColor: const Color(0xff7886c7),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              IgnorePointer(
                ignoring: _showInfoState,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TableCalendar<HabitLog>(
                          locale: "en_US",
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            headerMargin: const EdgeInsets.only(bottom: 10),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25),
                              ),
                            ),
                            titleTextStyle: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            markerDecoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            markersAlignment: Alignment.bottomCenter,
                            markersMaxCount: 3,
                            todayDecoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          firstDay: DateTime.utc(_today.year - 1, 1, 1),
                          lastDay: DateTime.utc(_today.year + 1, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getEventsForDay,
                          onDaySelected: _onDaySelected,
                        ),
                      ),
                    ),

                    for (final habit in _habits)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xfffff2f2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: GoogleFonts.openSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Total logs: ${_completionCountByHabit[habit.id] ?? 0}",
                                  style: GoogleFonts.openSans(fontSize: 16),
                                ),

                                const Spacer(),
                                
                                ElevatedButton(
                                  onPressed: () => _completeHabitToday(habit),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: const Size(double.infinity, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Complete Today",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _showEditHabitDialog(habit),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _confirmDeleteHabit(habit),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      onTapOutside:(_) {
                        setState(() {
                            _showInfoState = false; 
                            _selectedDay = null;
                            _focusedDay = _today;
                            });
                      },
                      child: Center(
                        child: Container(
                          height: 450,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: _buildSelectedDayPanel(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      );
  }
    Widget _buildSelectedDayPanel() {
    final sel = _selectedDay != null ? _dateOnly(_selectedDay!) : null;
    final friendlyDate = sel != null
        ? "${sel.year}-${sel.month.toString().padLeft(2, '0')}-${sel.day.toString().padLeft(2, '0')}"
        : "";
    final timeFormatter = DateFormat('h:mm a');

    final filtered = _completedOnly
      ? _selectedDayLogs.where((l) => l.completed).toList()
      : List<HabitLog>.from(_selectedDayLogs);

    filtered.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

     return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title + toggle
      Row(
        children: [
          Expanded(
            child: Text(
              "Habit Data — $friendlyDate",
              style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Row(
            children: [
              Text(
                _completedOnly ? "Completed" : "All",
                style: GoogleFonts.openSans(fontSize: 12),
              ),
              const SizedBox(width: 6),
              Switch(
                value: _completedOnly,
                onChanged: (v) => setState(() => _completedOnly = v),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),

      // List
      Expanded(
        child: filtered.isEmpty
            ? Center(
                child: Text(
                  _completedOnly ? "No completed logs for this day" : "No logs for this day",
                  style: GoogleFonts.openSans(fontSize: 15),
                ),
              )
            : ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, i) {
                  final log = filtered[i];
                  final habit = _habitById[log.habitId];
                  final name = habit?.name ?? "Habit ${log.habitId}";
                  final time = timeFormatter.format(DateTime.parse(log.date));

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      log.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: log.completed ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Logged at $time",
                      style: GoogleFonts.openSans(fontSize: 13),
                    ),
                  );
                },
              ),
      ),

      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            setState(() {
              _showInfoState = false;
              _selectedDay = null;
            });
          },
          child: const Text("Close"),
        ),
      ),
    ],
  );
  }
}