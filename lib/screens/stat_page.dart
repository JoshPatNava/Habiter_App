import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../controller/habit_controller.dart';
import '../models/habit.dart';

class StatPage extends StatefulWidget {
  @override
  State<StatPage> createState() => _MyStatPageState();  
}

class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;
  bool _weekdaysVisible = false;
  bool _panelOpen = false;
  double _panelPosition = 0;

  final PanelController _panelController = PanelController();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  final HabitController _habitController = HabitController();

  String? _habitName;
  String? _habitDesc;
  int? _habitFreq;
  List<int>? _weeklyFreq;
  List<DropdownMenuItem<int>> get frequencies{
    List<DropdownMenuItem<int>> freq = [
      DropdownMenuItem(value: 1, child: Text("Daily")),
      DropdownMenuItem(value: 2, child: Text("Weekly")),
    ];
    return freq;
  }

  List<Habit> _habits = [];
  bool _loading = true;

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
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height*0.8,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        color: Color(0xfffff2f2),
        defaultPanelState: PanelState.CLOSED,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        isDraggable: false,
        onPanelClosed: () {
            setState(() {
              _panelOpen = false;
            });
        },
        

        panel: Center(
          child: Stack(
            children: [
              FormBuilder(
                key: _formKey,
                skipDisabled: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'HabitName',
                        maxLength: 30,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                          hintText: "Your Habit Name", // name: _habitName.text
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 30),
                      FormBuilderTextField(
                        name: 'HabitDesc',
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                          hintText: "Description...", // name: _habitDesc.text
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
                          ]
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async{
                          if (_formKey.currentState!.saveAndValidate()) {
                            _habitName = _formKey.currentState!.value['HabitName'];
                            _habitDesc = _formKey.currentState!.value['HabitDesc'];
                            _habitFreq = _formKey.currentState!.value['HabitFreq'];
                            if(_weekdaysVisible) {
                              _weeklyFreq = _formKey.currentState!.value['WeeklyFreq'] as List<int>?;
                            }
                            
                            final newHabit = Habit(
                              name: _habitName!,
                              description: _habitDesc,
                              frequency: _habitFreq!,
                              startDate: DateTime.now(),
                              goalCount: _weekdaysVisible ? _weeklyFreq?.length : null,
                            );
                            
                            final messenger = ScaffoldMessenger.of(context);

                            try{
                              await _habitController.addHabit(newHabit);
                              await _loadHabits();

                              if (!mounted) return;

                              messenger.showSnackBar(
                                const SnackBar(content: Text('Habit Added Successfully!')),
                              );
                            } catch (e) {

                              if (!mounted) return;

                              messenger.showSnackBar(
                                SnackBar(content: Text('Failed to add habit: $e'))
                              );
                            }

                            _panelController.close();
                            _formKey.currentState?.reset();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ]
                  ),
                )
              ),
            ]
          ),
        ),
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
      ),
      floatingActionButton: IgnorePointer(
        ignoring: _panelOpen || _showStatState,
        // child: AnimatedOpacity(
        //   opacity: (!_showStatState && !_panelOpen) ? 1 : 0,
          // opacity: _panelPosition,
          // duration: Durations.medium1,
        child: Visibility(
          visible: !_showStatState && !_panelOpen,
          child: IgnorePointer(
            ignoring: _showStatState,
            child: FloatingActionButton(
              onPressed: () {
                if(!_panelController.isPanelOpen) {
                  setState(() {
                    _panelOpen = true;
                  });
                  _panelController.open();
                }
              }, 
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}