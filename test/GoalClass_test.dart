// ignore_for_file: unused_import, file_names

import 'dart:developer';
import 'dart:io';

import 'package:goal_tracker/goal_class.dart';
import 'package:test/test.dart';

main() {
  group('Goal Class', () {
    var goal = GoalClass(DateTime(2022), DateTime(2023), 12.0, "test");
    test('Information should be initialized', () {
      expect(goal.begin, DateTime(2022));
      expect(goal.end, DateTime(2023));
      expect(goal.percent, 0.12);
      expect(goal.name, "test");
    });

    test('Goal information should be changed', () {
      goal.editGoal(DateTime(2023), DateTime(2024), 40.0, "update");
      expect(goal.begin, DateTime(2023));
      expect(goal.end, DateTime(2024));
      expect(goal.percent, 0.40);
      expect(goal.name, "update");
    });

    test('Usable date should be properly formatted', () {
      expect(goal.usableDate(DateTime(2022, 1, 1)), "1/1/2022");
    });

    test('Milestones should be empty', () {
      expect(goal.milestones.length, 0);
    });

    test('Milestones should be properly added and hashable', () {
      goal.updateMilestones(DateTime(2022), "milestone test");
      expect(goal.milestones.length, 1);
      expect(goal.milestones[goal.usableDate(DateTime(2022))]![0],
          "milestone test");
    });

    test('Milestones on the same date are properly added and hashable', () {
      goal.updateMilestones(DateTime(2022), "second test");
      expect(goal.milestones.length, 1);
      expect(goal.milestones[goal.usableDate(DateTime(2022))]!.length, 2);
      expect(
          goal.milestones[goal.usableDate(DateTime(2022))]![1], "second test");
    });

    test('GetStringPercent returns the proper percentage as a string', () {
      expect(goal.getStringPercent(), '40.0');
    });

    log(goal.toJson.toString());
    test('toJson returns the correct serialization', () {
      Map<String, dynamic> testJson = goal.toJson();
      expect(testJson['name'], 'update');
      expect(testJson['percent'], 0.4);
      expect(testJson['begin'], "2023-01-01");
      expect(testJson['end'], "2024-01-01");
      expect(testJson['milestones']['1/1/2022'],
          ['milestone test', 'second test']);
    });
  });
}
