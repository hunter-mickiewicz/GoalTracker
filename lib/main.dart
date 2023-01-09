import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/GoalClass.dart';
import 'package:namer_app/goalClass.dart';
import 'package:provider/provider.dart';
import 'GoalClass.dart' as GC;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Goal Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 194, 11, 118)),
        ),
        home: Tracker(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var goalList = <GC.GoalClass>[];

  var selectedIndex = 0;

  void addGoal() {
    goalList.add(GC.GoalClass(DateTime.now(), DateTime.utc(2023, 12, 31), 0));
    notifyListeners();
  }
}

class Tracker extends StatefulWidget {
  @override
  State<Tracker> createState() => _Tracker();
}

class _Tracker extends State<Tracker> {
  @override
  Widget build(BuildContext ctx) {
    Widget page;
    var appState = ctx.watch<MyAppState>();
    switch (appState.selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ManagePage();
        break;
      default:
        page = Placeholder();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Tracker'),
        backgroundColor: Color.fromARGB(239, 21, 132, 196),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(239, 21, 132, 196),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: appState.selectedIndex,
        selectedItemColor: Color.fromARGB(255, 139, 12, 12),
        onTap: (index) {
          setState(() {
            appState.selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: Text('testing'),
    );
  }
}

class ManagePage extends StatefulWidget {
  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
