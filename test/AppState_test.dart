import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/GoalClass.dart';
import 'package:goal_tracker/main.dart';

void main() {
  testWidgets('AppState goal list should add item properly', (tester) async {
    final appState = MyAppState();

    final goal = GoalClass(DateTime(2022), DateTime(2023), 12, 'test');
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: GoalDisplay(
      appState: appState,
      goal: goal,
    ))));

    final widgetFinder = find.text('test');
    expect(widgetFinder, findsOneWidget);
  });
}
