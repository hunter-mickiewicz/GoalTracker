import 'package:namer_app/GoalClass.dart';
import 'package:test/test.dart';

main() {
  group('Goal Class', () {
    final goal = GoalClass(DateTime(2022), DateTime(2023), 12, "test");
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
  });
}
