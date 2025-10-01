import 'package:flutter/material.dart';
import 'home_screen.dart';

class StatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffffdada),
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage())
                  );
                },
              ),
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                icon: const Icon(Icons.add),
                onPressed: () {
                  
                },
              ),
              IconButton(
                color: Color(0xff2d336b),
                iconSize: 50,
                icon: const Icon(Icons.list_alt_outlined),
                onPressed: () {
                  
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}