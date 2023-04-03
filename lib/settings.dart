class Settings {
  late int recurringTime;

  Settings.def() {
    recurringTime = 1;
  }

  Settings.json(Map<String, dynamic> j) {
    recurringTime = j['recurringTime'];
  }

  int getRecurringTime() {
    return recurringTime;
  }

  Map<String, dynamic> toJson() => {
        'recurringTime': recurringTime,
      };

  Settings.fromJson(Map<String, dynamic> json)
      : recurringTime = json['recurringTime'];
}
