import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class StatPage extends StatefulWidget {
  @override
  State<StatPage> createState() => _MyStatPageState();  
}

class _MyStatPageState extends State<StatPage> {
  bool _showStatState = false;
  int _newFreq = 1;

  final PanelController _panelController = PanelController();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  String? _habitName;
  String? _habitDesc;
  int? _habitFreq;
  int? _weeklyFreq;
  List<DropdownMenuItem<int>> get frequencies{
    List<DropdownMenuItem<int>> freq = [
      DropdownMenuItem(value: 1, child: Text("Daily")),
      DropdownMenuItem(value: 2, child: Text("Weekly")),
      DropdownMenuItem(value: 3, child: Text("Monthly")),
    ];
    return freq;
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
        defaultPanelState: PanelState.CLOSED,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        isDraggable: false,
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
                            _newFreq = value ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      Visibility(
                        visible: _newFreq == 2,
                        child: FormBuilderCheckboxGroup(
                          name: 'Weekdays',
                          options: const [
                            FormBuilderFieldOption(value: 'Su'),
                            FormBuilderFieldOption(value: 'M'),
                            FormBuilderFieldOption(value: 'Tu'),
                            FormBuilderFieldOption(value: 'W'),
                            FormBuilderFieldOption(value: 'Th'),
                            FormBuilderFieldOption(value: 'F'),
                            FormBuilderFieldOption(value: 'Sa'),
                          ]
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            _habitName = _formKey.currentState!.value['HabitName'];
                            _habitDesc = _formKey.currentState!.value['HabitDesc'];
                            _habitFreq = _formKey.currentState!.value['HabitFreq'];
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
          child: Stack(
            children: <Widget> [ 
              IgnorePointer(
                ignoring: _showStatState,
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 100),
                  itemCount: 11,
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
                          "Habit ${index+1}",
                          style: GoogleFonts.openSans(
                            fontSize: 30,
                          ),
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
      floatingActionButton: AnimatedOpacity(
        opacity: (_panelController.isAttached && !_panelController.isPanelOpen) ? 1 : 0,
        duration: Durations.medium1,
        child: IgnorePointer(
          ignoring: _showStatState,
          child: FloatingActionButton(
            onPressed: () {
              if(!_panelController.isPanelOpen) {
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