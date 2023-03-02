import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

// ignore: file_names
class GoalClass {
  DateTime? begin;
  DateTime? end;
  double percent = 0;
  String? name;
  String? fileName;
  var milestones = <String, List<String>>{};

  String getStringPercent() {
    return (percent * 100).toString();
  }

  String updateFileName() {
    return fileName = createFileName(name!, begin!);
  }

  String usableDate(DateTime dt) {
    String useful = "${dt.month}/${dt.day}/${dt.year}";

    return useful;
  }

  String dataDate(DateTime dt) {
    return "${dt.month}-${dt.day}-${dt.year}";
  }

  String createFileName(String name, DateTime date) {
    int endIndex = name.length >= 7 ? 7 : name.length;
    return (name.substring(0, endIndex) + dataDate(date));
  }

  void editGoal(DateTime? st, DateTime? fn, double perc, String? nm) {
    begin = st;
    end = fn;
    percent = updatePercentage(perc);
    name = nm;
  }

  double updatePercentage(double perc) {
    double p = perc;
    if (perc >= 1.0) {
      p = perc / 100;
    }
    return p;
  }

  void updateMilestones(DateTime dt, String milestone) {
    String hashable = usableDate(dt);
    List<String> entries;

    if (milestones.containsKey(hashable)) {
      entries = milestones.putIfAbsent(hashable, () => [milestone]);
      entries.add(milestone);
      milestones.update(hashable, (entries) => entries);
    } else {
      milestones.putIfAbsent(hashable, () => [milestone]);
    }
  }

  GoalClass(DateTime? beginDate, DateTime? endDate, double startPercent,
      String? goalName) {
    begin = beginDate;
    end = endDate;
    name = goalName;
    percent = updatePercentage(startPercent);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'percent': percent,
        'begin': dataDate(begin!),
        'end': dataDate(end!),
        'milestones': milestones,
      };

  GoalClass.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        percent = json['percent'],
        begin = json['begin'],
        end = json['end'],
        milestones = json['milestones'];

  String print() {
    return """
      name: $name,
      percent: $percent,
      begin: ${dataDate(begin!)},
      end: ${dataDate(end!)},
      milestones: $milestones
    """;
  }
}
