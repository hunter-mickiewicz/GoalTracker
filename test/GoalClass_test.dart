import 'package:namer_app/GoalClass.dart';
import 'package:test/test.dart';

main() {
  group('Goal Class', () {
    var goal = GoalClass(DateTime(2022), DateTime(2023), 12.0, "test");
    test('Beginning date should be initialized', () {
      expect(goal.begin, DateTime(2022));
    });
    test('End date should be initialized', () {
      expect(goal.end, DateTime(2023));
    });
    test('Percentage should be initialized', () {
      expect(goal.percent, 0.12);
    });
    test('Name should be initialized', () {
      expect(goal.name, "test");
    });

    var goal2 = GoalClass(DateTime(2022), DateTime(2023), 12.0, "test");
    goal2.editGoal(DateTime(2023), DateTime(2024), 40.0, "update");
    test('Beginning date should be changed', () {
      expect(goal2.begin, DateTime(2023));
    });
    test('End date should be changed', () {
      expect(goal2.end, DateTime(2024));
    });
    test('Percentage should be changed', () {
      expect(goal2.percent, 0.40);
    });
    test('Name should be changed', () {
      expect(goal2.name, "update");
    });

    test('Milestones should be empty', () {
      expect(goal.milestones.length, 0);
    });
    //add/edit milestone
  });
}
