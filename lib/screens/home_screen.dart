import 'package:flutter/material.dart';
import 'stat_page.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff7886c7),
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [

            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                height: 200,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xfffff2f2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                height: 200,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xfffff2f2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                height: 200,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xfffff2f2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                height: 200,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xfffff2f2),
                ),
              ),
            ),

          ],
        ),
      ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatPage())
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}