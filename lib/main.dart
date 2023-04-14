// ignore_for_file: library_private_types_in_public_api

import 'dart:collection';
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goal_tracker/settings.dart';

import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart' as perc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';
import 'file_io.dart';
import 'goal_class.dart' as gc;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

String localTimeZone = "";
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
  await readAddGoals();
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      // //drawable/res_app_icon for a custom icon
      'resource://drawable/notification',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  runApp(MyApp());
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }
}

var goalList = <gc.GoalClass>[];
//There will be one Settings object per app.
Settings? settings;
bool firstTimeFlag = false;

Future<List<gc.GoalClass>?> readAddGoals() async {
  FileIO reader = FileIO();

  void readInGoal(File file) async {
    String jsonContents = await reader.readInput(File(file.path));

    if (jsonContents.isNotEmpty) {
      Map<String, dynamic> jsonGoal = jsonDecode(jsonContents);

      String begin = jsonGoal["begin"].toString().replaceAll(".", "-");
      String end = jsonGoal["end"].toString().replaceAll(".", "-");
      goalList.add(gc.GoalClass(DateTime.parse(begin), DateTime.parse(end),
          jsonGoal["percent"], jsonGoal["name"], jsonGoal['notification']));
    } else {
      file.delete();
    }
  }

  String path = await _localPath;

  for (var file in Directory(path).listSync()) {
    if (file.toString().contains("settings.txt")) {
      //reads in the settings file, decodes as JSON
      String settingsString = await reader.readInput(File(file.path));
      var decoded = json.decode(settingsString);

      settings = Settings.json(decoded);
      settings?.notificationPreference = false;
    } else if (file.toString().contains(".txt")) {
      readInGoal(File(file.path));
    }
  }
  if (settings == null) {
    log("No settings found! :(");
    settings = Settings.def();
    reader.writeSettings(settings!);
    firstTimeFlag = true;
  }

  return goalList;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        home: ChangeNotifierProvider(
          create: (context) => MyAppState(),
          child: MaterialApp(
            title: 'Goal Tracker',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Color.fromARGB(255, 194, 11, 118)),
            ),
            home: Tracker(),
          ),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var goalList = <gc.GoalClass>[];
  // ignore: prefer_typing_uninitialized_variables
  var currGoal;
  bool editingMode = false;

  var appBarIndex = 0;
  var pageIndex = 0;

  gc.GoalClass addTestGoal() {
    gc.GoalClass goal = gc.GoalClass(
        DateTime.now(), DateTime.utc(2023, 12, 31), 0.69, "test", "");
    goalList.add(goal);
    goalList[0].updateMilestones(DateTime.now(), "test milestone");

    notifyListeners();
    return goal;
  }

  void testJson(gc.GoalClass goal) async {
    FileIO reader = FileIO();

    reader.writeGoal(goal);
  }

  void addGoal(gc.GoalClass goal) {
    FileIO writer = FileIO();
    goalList.add(goal);
    writer.writeGoal(goal);

    notifyListeners();
  }

  void removeGoal(gc.GoalClass goal) {
    FileIO deleter = FileIO();
    deleter.delete(currGoal);
    goalList.remove(goal);

    notifyListeners();
  }
}

class Tracker extends StatefulWidget {
  @override
  State<Tracker> createState() => _Tracker();
}

class _Tracker extends State<Tracker> {
  @override
  Widget build(BuildContext ctx) {
    Widget page;
    var appState = ctx.watch<MyAppState>();
    appState.goalList = goalList;
    //appState.readAddGoals();

    //Nickie insists this will fix all my problems;
    //9u6

    //appState.pageIndex = appState.appBarIndex;
    switch (appState.pageIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = SettingsPage();
        break;
      default:
        page = Placeholder();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Tracker'),
        backgroundColor: Color.fromARGB(239, 21, 132, 196),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(239, 21, 132, 196),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: appState.appBarIndex, //appState.selectedIndex,
        selectedItemColor: Color.fromARGB(255, 139, 12, 12),
        onTap: (index) {
          setState(() {
            appState.appBarIndex = index;
            appState.pageIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();
    var goals = goalList;

    var msg = '';

    if (goals.isEmpty) {
      msg = 'No goals';
    }

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text(msg)),
          ),
          for (var goal in goals)
            Card(
              child: Builder(builder: (context) {
                return GoalDisplay(appState: appState, goal: goal);
              }),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        //gc.GoalClass goal = appState.addTestGoal();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalCreatorPage()),
        );

        //TEST schedule, add goal
        /*AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: 10,
                channelKey: 'basic_channel',
                title: 'Simple Notification',
                body: 'Simple body',
                actionType: ActionType.Default),
            schedule: NotificationCalendar(
                second: 0, minute: 51, hour: 9, repeats: true));
            FileIO writer = FileIO();
            writer.writeGoal(goal);*/
      }),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void updateSettings(int setting, int val) async {
    FileIO writer = FileIO();

    switch (setting) {
      case 0:
        val == 0
            ? settings!.notificationPreference = false
            : settings!.notificationPreference = true;
        setState(() {
          writer.writeSettings(settings!);
        });
        break;
      default:
        throw UnimplementedError();
    }
  }

  List<String> notifPref = ["Single", "Per Goal"];

  @override
  Widget build(BuildContext context) {
    void sendEmail(String type) async {
      Email email = Email(
        subject: "Goal Tracker: $type",
        recipients: ["agreenstormproject@gmail.com"],
        body: "",
      );
      await FlutterEmailSender.send(email);
    }

    return Scaffold(
        body: ListView(
      children: [
        ListTile(
          title: Text("Notification Preference"),
          subtitle: Text(settings!.getNotifPref()),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                        child: ListView(shrinkWrap: true, children: <Widget>[
                      ListTile(
                        title: Text(notifPref[0]),
                        onTap: () {
                          updateSettings(0, 0);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(notifPref[1]),
                        onTap: () {
                          updateSettings(0, 1);
                          Navigator.pop(context);
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("Alert"),
                                    content: Text(
                                        "With this setting, there will be one notification per goal. Make sure to update your goals with a notification day/time."),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Confirm"))
                                    ],
                                  ));
                        },
                      ),
                    ])));
          },
        ),
        Divider(),
        ListTile(
          title: Text("Cancel Notifications"),
          onTap: () {
            AwesomeNotifications().cancelAll();
          },
        ),
        Divider(),
        ListTile(
          title: Text("Contact Us"),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            "What type of feedback do you have?",
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          ListTile(
                            title: Text("Bug Report"),
                            onTap: () {
                              sendEmail("Bug Report");
                            },
                          ),
                          ListTile(
                            title: Text("Feature Request"),
                            onTap: () {
                              sendEmail("Feature Request");
                            },
                          ),
                          ListTile(
                            title: Text("Other Comment"),
                            onTap: () {
                              sendEmail("Other Comment");
                            },
                          ),
                        ],
                      ),
                    ));
          },
        ),
        Divider(),
        ListTile(title: Text("About")),
      ],
    ));
  }
}

class GoalDisplay extends StatelessWidget {
  const GoalDisplay({
    super.key,
    required this.appState,
    required this.goal,
  });

  final MyAppState appState;
  final gc.GoalClass goal;

  @override
  Widget build(BuildContext context) {
    Future<void> editGoalClick() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoalEditPage()),
      );
      appState.goalList.remove(appState.currGoal);
      if (appState.currGoal != null) {
        appState.goalList.add(appState.currGoal);
      }
    }

    return ListTile(
      onTap: () {
        appState.currGoal = goal;
        editGoalClick();
      },
      minVerticalPadding: 2,
      tileColor: Color.fromARGB(255, 78, 167, 118),
      title: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${goal.name}"),
            Text("${goal.getStringPercent()}%"),
          ]),
          perc.LinearPercentIndicator(
            percent: goal.percent.toDouble(),
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
          ),
        ],
      ),
      subtitle:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "${goal.begin!.month}/${goal.begin!.day}/${goal.begin!.year}",
        ),
        Text(" "),
        Text(
          "${goal.end!.month}/${goal.end!.day}/${goal.end!.year}",
        ),
      ]),
    );
  }
}

// ignore: must_be_immutable
class GoalCreatorPage extends StatefulWidget {
  bool editingMode = false;
  @override
  State<GoalCreatorPage> createState() => _GoalCreatorPageState();
}

class _GoalCreatorPageState extends State<GoalCreatorPage> {
  String? goalName;
  List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  List<bool> daysSelected = List<bool>.generate(7, (int index) => false);
  String notificationDays = "Select Days";
  TimeOfDay? notifTime;
  String notificationTime = "Select Time";
  DateTime? begin;
  String beginString = "Start Date";
  DateTime? end;
  String endString = "End Date";
  bool confirmReady = false;
  double? percent;
  TextEditingController nameCont = TextEditingController();
  TextEditingController percCont = TextEditingController();

  void saveGoal() {}

  Future<void> _beginDateSelection() async {
    begin = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    setState(() {
      if (begin != null) {
        beginString = "${begin!.month}/${begin!.day}/${begin!.year}";
      }
    });
  }

  Future<void> _endDateSelection() async {
    end = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    setState(() {
      if (end != null) {
        endString = "${end!.month}/${end!.day}/${end!.year}";
      }
    });
  }

  Future<void> _getNotifTime() async {
    notifTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      if (notifTime != null) {
        String tempTime = notifTime.toString();
        notificationTime = tempTime.substring(
            tempTime.indexOf("(") + 1, tempTime.indexOf(")"));
      }
    });
  }

  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();

    Future<void> _selectNotifDays() async {
      showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
                  child: DataTable(
                columns: <DataColumn>[DataColumn(label: Text("Day"))],
                rows: List<DataRow>.generate(
                    weekDays.length,
                    (int index) => DataRow(
                        cells: <DataCell>[DataCell(Text(weekDays[index]))],
                        selected: daysSelected[index],
                        onSelectChanged: (bool? value) {
                          setState(() {
                            daysSelected[index] = value!;
                          });
                        })),
              )));
    }

    void changeGoal() {
      begin != null ? begin = begin : begin = appState.currGoal.begin;
      end != null ? end = end : end = appState.currGoal.end;
      percent != null
          ? percent = percent! / 100
          : percent = appState.currGoal.percent;
      goalName != null
          ? goalName = goalName
          : goalName = appState.currGoal.name;
      appState.currGoal.editGoal(begin, end, percent, goalName);
    }

    void addGoal() {
      if (appState.editingMode) {
        changeGoal();
      } else {
        gc.GoalClass goal = gc.GoalClass(begin, end, percent!, goalName, "");
        appState.addGoal(goal);
        begin = null;
        end = null;
        goalName = null;
        percent = null;
      }
    }

    void checkReady() {
      if (appState.editingMode ||
          (begin != null &&
              end != null &&
              goalName != null &&
              percent != null &&
              notifTime != null)) {
        confirmReady = true;
      } else {
        confirmReady = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.editingMode ? "Edit Goal" : "New Goal"),
      ),
      body: Column(
        children: [
          Text("Goal Name"),
          TextField(
            controller: nameCont,
            decoration: InputDecoration(
                focusColor: Color.fromARGB(255, 100, 98, 98),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20)),
            onChanged: (text) {
              setState(() {
                goalName = text;
                checkReady();
              });
            },
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _beginDateSelection();
                  checkReady();
                });
              },
              child: Text(beginString),
            ),
            OutlinedButton(
                onPressed: () {
                  setState(() {
                    _endDateSelection();
                    checkReady();
                  });
                },
                child: Text(endString)),
          ]),

          Text("Enter your percentage to completion"),
          //error on any kind of text input here...
          TextField(
            controller: percCont,
            decoration: InputDecoration(
                focusColor: Color.fromARGB(255, 100, 98, 98),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20)),
            onChanged: (text) {
              setState(() {
                percent = double.tryParse(text);
                checkReady();
              });
            },
          ),
          Text("What time do you want the reminder notification?"),
          OutlinedButton(
              onPressed: () {
                setState(() {
                  _getNotifTime();
                  checkReady();
                });
              },
              child: Text(notificationTime)),
          Text("What days do you want the notification to repeat?"),
          OutlinedButton(
              onPressed: () async {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => NotifDay(
                            weekDays: weekDays,
                            selectedDays: daysSelected,
                          ));
                });
                checkReady();
              },
              child: Text("Select Days")),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                  child: Text("Cancel")),
              // ignore: sort_child_properties_last

              OutlinedButton(
                onPressed: confirmReady
                    ? () {
                        appState.editingMode ? changeGoal() : addGoal();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text("Submit"),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class NotifDay extends StatefulWidget {
  const NotifDay(
      {super.key, required this.weekDays, required this.selectedDays});

  final List<bool> selectedDays;
  final List<String> weekDays;

  @override
  _NotifDayState createState() => _NotifDayState();
}

class _NotifDayState extends State<NotifDay> {
  _NotifDayState();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: DataTable(
      columns: <DataColumn>[DataColumn(label: Text("Day"))],
      rows: List<DataRow>.generate(
          widget.weekDays.length,
          (int index) => DataRow(
              cells: <DataCell>[DataCell(Text(widget.weekDays[index]))],
              selected: widget.selectedDays[index],
              onSelectChanged: (bool? value) {
                setState(() {
                  widget.selectedDays[index] = value!;
                });
              })),
    ));
  }
}

class GoalEditPage extends StatefulWidget {
  @override
  _GoalEditPageState createState() => _GoalEditPageState();
}

class _GoalEditPageState extends State<GoalEditPage> {
  Future<void> goToEdit() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => GoalCreatorPage()));
  }

  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();

    Future<void> deleteGoal() async {
      switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            alignment: Alignment.center,
            title: Text("Are you sure you want to delete this goal?"),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Text("Delete"),
                  ),
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 1);
                      },
                      child: Text("Cancel"))
                ],
              )
            ],
          );
        },
      )) {
        case 0:
          setState(() {
            appState.removeGoal(appState.currGoal);
          });
          Navigator.pop(context);
          appState.currGoal = null;
          break;
        case 1:
          break;
        default:
          break;
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(appState.currGoal == null ? "" : appState.currGoal.name),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllMilestonesPage()));
                    },
                    child: Text("View Milestones")),
                OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMilestonePage()));
                    },
                    child: Text("Add Milestone")),
                OutlinedButton(
                    onPressed: () {
                      appState.editingMode = true;
                      goToEdit();
                    },
                    child: Text("Edit Goal")),
                OutlinedButton(
                    onPressed: () {
                      deleteGoal();
                    },
                    child: Text("Delete Goal")),
                Text(""),
              ],
            ),
          ],
        ));
  }
}

class AllMilestonesPage extends StatefulWidget {
  @override
  _AllMilestonesPageState createState() => _AllMilestonesPageState();
}

class _AllMilestonesPageState extends State<AllMilestonesPage> {
  String msg = "";

  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();
    final sorted = SplayTreeMap<String, dynamic>.from(
        appState.currGoal.milestones, (a, b) => a.compareTo(b));

    if (appState.currGoal.milestones.isEmpty) {
      msg = "No milestones yet";
    }

    return Scaffold(
        appBar: AppBar(title: Text("Milestones")),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text(msg)),
          ),
          for (var entry in sorted.entries)
            for (var val in entry.value)
              Card(child: Builder(builder: (context) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(val),
                );
              }))
        ]));
  }
}

class AddMilestonePage extends StatefulWidget {
  @override
  _AddMilestonePageState createState() => _AddMilestonePageState();
}

class _AddMilestonePageState extends State<AddMilestonePage> {
  DateTime? milestoneDate;
  String milestoneDateString = "Milestone Date";
  TextEditingController milestoneCont = TextEditingController();
  String? milestone;
  bool dateBool = false;
  bool textBool = false;
  bool confirmBool = false;
  double? perc = 0;

  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();
    Future<void> addMilestoneDate() async {
      milestoneDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)));

      setState(() {
        if (milestoneDate != null) {
          milestoneDateString =
              "${milestoneDate!.month}/${milestoneDate!.day}/${milestoneDate!.year}";
          dateBool = true;
        }
      });
    }

    void addMilestone() {
      appState.currGoal.updateMilestones(milestoneDate, milestone);
      appState.currGoal.updatePercentage(perc);
    }

    void checkBools() {
      if (dateBool && textBool) {
        confirmBool = true;
      }
    }

    return Scaffold(
        appBar: AppBar(title: Text("New Milestone")),
        body: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  addMilestoneDate();
                });
              },
              child: Text(milestoneDateString),
            ),
          ]),
          Text(""),
          Row(
            children: [
              Expanded(
                child: Column(children: [
                  Text("Enter your milestone"),
                  TextField(
                    controller: milestoneCont,
                    decoration: InputDecoration(
                        focusColor: Color.fromARGB(255, 100, 98, 98),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                    onChanged: (text) {
                      setState(() {
                        milestone = text;
                        textBool = true;
                        checkBools();
                      });
                    },
                  ),
                ]),
              )
            ],
          ),
          Text(""),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Enter additional percentage completed"),
                    TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            focusColor: Color.fromARGB(255, 100, 98, 98),
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20)),
                        onChanged: (text) {
                          setState(() {
                            perc = double.tryParse(text);
                          });
                        })
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              OutlinedButton(
                onPressed: confirmBool
                    ? () {
                        addMilestone();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text("Submit"),
              )
            ],
          )
        ]));
  }
}
