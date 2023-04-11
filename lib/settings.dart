class Settings {
  late int recurringTime;
  late bool notificationPreference;

  Settings.def() {
    recurringTime = 1;

    //false == 1 notification per app
    notificationPreference = false;
  }

  Settings.json(Map<String, dynamic> j) {
    recurringTime = j['recurringTime'];
  }

  String getNotifPref() {
    return notificationPreference ? "Per Goal" : "Single";
  }

  int getRecurringTime() {
    return recurringTime;
  }

  Map<String, dynamic> toJson() => {
        'recurringTime': recurringTime,
        'notificationPreference': notificationPreference,
      };

  Settings.fromJson(Map<String, dynamic> json)
      : recurringTime = json['recurringTime'],
        notificationPreference = json['notificationPreference'];
}
