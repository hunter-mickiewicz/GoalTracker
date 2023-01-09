import 'package:flutter/material.dart';

class GoalClass {
  DateTime? begin;
  DateTime? end;
  int? percent;

  GoalClass(var beginDate, var endDate, var startPercent) {
    begin = beginDate;
    end = endDate;
    percent = startPercent;
  }
}
