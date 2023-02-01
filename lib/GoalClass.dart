// ignore: file_names
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
}
