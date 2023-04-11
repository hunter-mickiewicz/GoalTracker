// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:goal_tracker/file_io.dart';
import 'package:goal_tracker/goal_class.dart';
import 'package:goal_tracker/main.dart';

void main() {
  final appState = MyAppState();
  final goal = GoalClass(DateTime(2022), DateTime(2023), 12, 'test', "");
  //FileIO fileDoodad = FileIO();
  testWidgets('AppState goal list should add item properly', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: GoalDisplay(
      appState: appState,
      goal: goal,
    ))));

    final widgetFinder = find.text('test');
    expect(widgetFinder, findsOneWidget);
  });

  //testWidgets('Goal file should be written', (tester) async {});
  //testWidgets('Goal file should be read', (tester) async{});
  //testWidgets('Goal file should be deleted', (tester) async{});

  //These three will be tough, since I can't access the directory during testing...
  //Need to separate functions out, test that it:
  //correctly encodes/decodes to/from JSON
  //saves a file (somewhere)

  testWidgets('', (tester) async {});
}
