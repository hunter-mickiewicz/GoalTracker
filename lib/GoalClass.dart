import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  double percent = 0;
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

  void updatePercentage(double perc) {
    percent += perc / 100;
  }

  void updateMilestones(DateTime dt, String milestone) {
    String hashable = usableDate(dt);
    var entries;

    if (milestones.containsKey(hashable)) {
      entries = milestones.putIfAbsent(hashable, () => [milestone]);
      entries.add(milestone);
      milestones.update(hashable, (entries) => entries);
    } else {
      milestones.putIfAbsent(hashable, () => [milestone]);
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
