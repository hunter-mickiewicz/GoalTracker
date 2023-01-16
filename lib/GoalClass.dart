import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  double? percent;
  String? name;
  var milestones = <DateTime, List<String>>{};

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

    if (milestones.containsKey(hashable)) {
      //add to array
    } else {
      //instantiate array for key
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
