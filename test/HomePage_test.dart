import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/GoalClass.dart';
import 'package:goal_tracker/main.dart';

void main() {
  testWidgets('Should display nothing if no goals are set',
      (WidgetTester tester) async {
    final home = HomePage();
    final goal = GoalClass(DateTime(2022), DateTime(2023), 12, 'test');
  });
}
