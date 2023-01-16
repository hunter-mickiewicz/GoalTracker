import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  double? percent;
  String? name;

  String getStringPercent() {
    return (percent! * 100).toString();
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
