import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../controller/habit_controller.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();  
}


class _MyHomePageState extends State<MyHomePage> {
  //Controller OBJ
  final HabitController controller = HabitController();

  final PanelController _panelController = PanelController();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _weekdaysVisible = false;

  List<DropdownMenuItem<int>> get frequencies {
    return [
      DropdownMenuItem(value: 1, child: Text("Daily")),
      DropdownMenuItem(value: 2, child: Text("Weekly")),
    ];
  }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAll(); 
    });
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
        completionCountByHabit[habit.id!] =
          logs.where((log) => log.completed).length;
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

  Future<void> _submitHabit() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final data = _formKey.currentState!.value;

      final newHabit = Habit(
        name: data['HabitName'],
        description: data['HabitDesc'],
        frequency: data['HabitFreq'],
        startDate: DateTime.now(),
        goalCount:
            _weekdaysVisible ? (data['WeeklyFreq'] as List<int>?)?.length : null,
      );

      await controller.addHabit(newHabit);
      await _loadAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Habit Added!")),
        );
      }

      _panelController.close();
      _formKey.currentState?.reset();
    }
}

Widget _buildAddHabitForm() {
    return FormBuilder(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'HabitName',
              maxLength: 30,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                hintText: "Your Habit Name",
              ),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 30),

            FormBuilderTextField(
              name: 'HabitDesc',
              maxLength: 100,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                hintText: "Description...",
              ),
            ),
            const SizedBox(height: 30),

            FormBuilderDropdown<int>(
              name: 'HabitFreq',
              items: frequencies,
              initialValue: 1,
              onChanged: (value) {
                setState(() {
                  _weekdaysVisible = (value == 2);
                });
              },
            ),
            const SizedBox(height: 30),

            Visibility(
              visible: _weekdaysVisible,
              child: FormBuilderCheckboxGroup(
                name: 'WeeklyFreq',
                options: const [
                  FormBuilderFieldOption(value: 1, child: Text('Su')),
                  FormBuilderFieldOption(value: 2, child: Text('M')),
                  FormBuilderFieldOption(value: 3, child: Text('Tu')),
                  FormBuilderFieldOption(value: 4, child: Text('W')),
                  FormBuilderFieldOption(value: 5, child: Text('Th')),
                  FormBuilderFieldOption(value: 6, child: Text('F')),
                  FormBuilderFieldOption(value: 7, child: Text('Sa')),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitHabit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
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
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.redAccent,
      onPressed: () {
        _panelController.open();
      },
    ),
    body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        color: Color(0xfffff2f2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),

        panel: _buildAddHabitForm(),

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
      ),
    );
  }
    Widget _buildSelectedDayPanel() {
    final sel = _selectedDay != null ? _dateOnly(_selectedDay!) : null;
    final friendlyDate = sel != null
        ? "${sel.year}-${sel.month.toString().padLeft(2, '0')}-${sel.day.toString().padLeft(2, '0')}"
        : "";

    final filtered = _completedOnly
      ? _selectedDayLogs.where((l) => l.completed).toList()
      : List<HabitLog>.from(_selectedDayLogs);

    filtered.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

     return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
                      "Completed ",
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