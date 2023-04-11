// ignore: file_names
class GoalClass {
  DateTime? begin;
  DateTime? end;
  //current idea, "hour,interval", the hour, then the interval between
  late String notification;
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
    return "${dt.year}-${dt.month.toString().length >= 2 ? dt.month : "0${dt.month}"}-${dt.day.toString().length >= 2 ? dt.day : "0${dt.day}"}";
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
      String? goalName, String notif) {
    begin = beginDate;
    end = endDate;
    name = goalName;
    percent = updatePercentage(startPercent);
    notification = notif;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'percent': percent,
        'begin': dataDate(begin!),
        'end': dataDate(end!),
        'milestones': milestones,
        'notification': notification,
      };

  GoalClass.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        percent = json['percent'],
        begin = json['begin'],
        end = json['end'],
        milestones = json['milestones'],
        notification = json['notification'];

  String print() {
    return """
      name: $name,
      percent: $percent,
      begin: ${dataDate(begin!)},
      end: ${dataDate(end!)},
      milestones: $milestones,
      notification: $notification
    """;
  }
}
