class GoalClass {
  DateTime? begin;
  DateTime? end;
  double percent = 0;
  String? name;
  var milestones = <String, List<String>>{};

  String getStringPercent() {
    return (percent * 100).toString();
  }

  String usableDate(DateTime dt) {
    String useful = "${dt.month}/${dt.day}/${dt.year}";

    return useful;
  }

  void editGoal(DateTime? st, DateTime? fn, double perc, String? nm) {
    begin = st;
    end = fn;
    percent = perc;
    name = nm;
  }

  void updatePercentage(double perc) {
    percent += perc / 100;
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
