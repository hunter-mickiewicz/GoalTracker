import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  double? percent;
  String? name;
  var milestones = <String, List<String>>{};

  String getStringPercent() {
    return (percent! * 100).toString();
  }

  String usableDate(DateTime dt) {
    String useful = "${dt.month}/${dt.day}/${dt.year}";

    return useful;
  }

  void editGoal() {}

  void updateMilestones(DateTime dt, String milestone) {
    String hashable = usableDate(dt);

    var entries = milestones.putIfAbsent(hashable, () => [milestone]);

    if (milestones.containsKey(hashable)) {
      entries.add(milestone);
      milestones.update(hashable, (entries) => entries);
    }
  }

  GoalClass(var beginDate, var endDate, var startPercent, var goalName) {
    begin = beginDate;
    end = endDate;
    name = goalName;

    if (startPercent > 1.0) {
      percent = startPercent / 100;
    } else {
      percent = startPercent;
    }
  }
}
