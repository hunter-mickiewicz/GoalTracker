import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  double? percent;

  String getStringPercent() {
    return (percent! * 100).toString();
  }

  GoalClass(var beginDate, var endDate, var startPercent) {
    begin = beginDate;
    end = endDate;
    percent = startPercent;
  }
}
