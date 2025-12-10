import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  bool _panelUp = false;

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
        _loadAll(); 
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _loadAll() async {
  try {
    final habits = await controller.getAllHabits();

    final habitById = <int, Habit>{};
    final logsByDay = <DateTime, List<HabitLog>>{};
    final completionCount = <int, int>{};

    for (final h in habits) {
      habitById[h.id!] = h;

      final logs = await controller.getHabitLogs(h.id!);

      completionCount[h.id!] =
          logs.where((l) => l.completed).length;

      for (final log in logs) {
        final parts = log.date.split('-');
        final normalized = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        logsByDay.putIfAbsent(normalized, () => []).add(log);
      }
    }

    if (!mounted) return; 

    setState(() {
      _habits = habits;
      _habitById = habitById;
      _logsByDay = logsByDay;
      _completionCountByHabit = completionCount;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load data: $e')),
    );
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
              maxLength: 20,
              style: Theme.of(context).textTheme.titleMedium,
              cursorColor: Theme.of(context).colorScheme.outline,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, 
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, 
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                ),
                hintText: "Your Habit Name",
                hintStyle: Theme.of(context).textTheme.titleMedium,
                counterStyle: Theme.of(context).textTheme.labelMedium,
              ),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 30),

            FormBuilderTextField(
              name: 'HabitDesc',
              maxLength: 100,
              style: Theme.of(context).textTheme.titleMedium,
              cursorColor: Theme.of(context).colorScheme.outline,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                ),
                hintText: "Description...",
                hintStyle: Theme.of(context).textTheme.titleMedium,
                counterStyle: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 30),

            FormBuilderDropdown<int>(
              name: 'HabitFreq',
              items: frequencies,
              dropdownColor: Theme.of(context).colorScheme.tertiary,
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
                options: [
                  FormBuilderFieldOption(value: 1, child: Text('Su', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 2, child: Text('M', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 3, child: Text('Tu', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 4, child: Text('W', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 5, child: Text('Th', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 6, child: Text('F', style: Theme.of(context).textTheme.labelLarge)),
                  FormBuilderFieldOption(value: 7, child: Text('Sa', style: Theme.of(context).textTheme.labelLarge)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                _submitHabit();
                FocusScope.of(context).unfocus();
              },
              child: Text(
                'Submit', 
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ),
          ],
        ),
      ),
    );
  }


List<HabitLog> _getEventsForDay(DateTime day) {
  final list = _logsByDay[_dateOnly(day)] ?? [];
  return list;
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
          title: Text("Delete Habit", style: Theme.of(context).textTheme.titleLarge),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          content: Text(
            "Are you sure you want to delete the habit \"${habit.name}\"? This action cannot be undone.",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text("Cancel", style: Theme.of(context).textTheme.labelLarge),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await controller.deleteHabit(habit.id!);
                await _loadAll(); // Refresh data
              },
              child: Text(
                "Delete",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
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
          title: Text("Edit Habit", style: Theme.of(context).textTheme.titleLarge),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          content: TextField(
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 19),
            controller: nameCtrl,
            maxLength: 20,
            cursorColor: Theme.of(context).colorScheme.outline,
            decoration: InputDecoration(
              labelText: "Habit name",
              labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17),
              counterStyle: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh),
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  final updated = habit.copyWith(name: newName);
                  await controller.updateHabit(updated);
                  await _loadAll();
                }
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Save",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeHabitToday(Habit habit) async {
   await controller.toggleCompletion(
     habitId: habit.id!,
     day: DateTime.now(),
     completed: true,
   );

  await _loadAll(); 
}

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    floatingActionButton: IgnorePointer(
      ignoring: _panelUp,
      child: AnimatedOpacity(
        opacity: _panelUp ? 0.0 : 1.0,
        duration: Durations.medium1,
        child: FloatingActionButton(
          onPressed: () {
            _panelController.open();
          },
          child: Icon(Icons.add),
        ),
      ),
    ),
    body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        backdropEnabled: true,
        onPanelClosed: () => _formKey.currentState?.reset(),
        onPanelSlide: (position) {
          FocusScope.of(context).unfocus();
          if (_panelUp && position < 0.5) {
            setState(() {
              _panelUp = false;
            });
            return;
          }
          if (!_panelUp && position > 0.5) {
            setState(() {
              _panelUp = true;
            });
            return;
          }
        },

        panel: _buildAddHabitForm(),

        body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              IgnorePointer(
                ignoring: _showInfoState,
                child: ListView(
                  padding: EdgeInsets.only(bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70, bottom: 30, left: 20, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TableCalendar<HabitLog>(
                          key: ValueKey(_habits.length + _completionCountByHabit.length),
                          availableGestures: AvailableGestures.all,
                          locale: "en_US",
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            headerMargin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25),
                              ),
                            ),
                            titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                          ),
                          calendarStyle: CalendarStyle(
                            markerDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle: Theme.of(context).textTheme.labelLarge!,
                            weekendTextStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).textTheme.labelLarge!.color!.withAlpha(128),
                            ),
                            markersAlignment: Alignment.bottomCenter,
                            markersMaxCount: 3,
                            todayDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekendStyle: Theme.of(context).textTheme.labelLarge!,
                            weekdayStyle: Theme.of(context).textTheme.labelLarge!,
                          ),
                          calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;

                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4), // adjust spacing
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                          firstDay: DateTime.utc(_today.year - 1, 1, 1),
                          lastDay: DateTime.utc(_today.year + 1, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getEventsForDay,
                          onDaySelected: _onDaySelected,
                          onPageChanged: (day) {
                            _focusedDay = day;
                          },
                        ),
                      ),
                    ),

                    for (final habit in _habits)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Total completions: ${_completionCountByHabit[habit.id] ?? 0}",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                
                                ElevatedButton(
                                  onPressed: () => _completeHabitToday(habit),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                    minimumSize: const Size(double.infinity, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Complete Today",
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.surfaceContainerLow),
                                      onPressed: () => _showEditHabitDialog(habit),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.surfaceContainerLowest),
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
                      onTapOutside:(_) async{
                        setState(() {
                            _showInfoState = false; 
                            _selectedDay = null;
                            _focusedDay = _today;
                            _selectedDayLogs = [];
                            });
                            await _loadAll();
                      },
                      child: Center(
                        child: Container(
                          height: 450,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
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

      DateTime parseDate(String d) {
        final p = d.split('-');
        return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      }

      filtered.sort((a, b) => parseDate(b.date).compareTo(parseDate(a.date)));

     return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              "Habit Data — $friendlyDate",
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 16, 
                  color: Theme.of(context).colorScheme.outline,
                ),
                itemBuilder: (context, i) {
                  final log = filtered[i];
                  final habit = _habitById[log.habitId];
                  final name = habit?.name ?? "Habit ${log.habitId}";

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      log.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: log.completed ? Theme.of(context).colorScheme.surfaceContainerHigh : Colors.grey,
                    ),
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      log.completed ? "Completed" : "Not completed",
                      style: Theme.of(context).textTheme.labelLarge,
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
              _selectedDayLogs = [];
            });
          },
          child: const Text("Close"),
        ),
      ),
    ],
  );
  }
}