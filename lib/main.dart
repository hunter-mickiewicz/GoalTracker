import 'dart:collection';
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'package:goal_tracker/settings.dart';

import 'local_notice_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart' as perc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FileIO.dart';
import 'GoalClass.dart' as gc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
  await readAddGoals();
  await LocalNoticeService().setup();
  runApp(MyApp());
}

var goalList = <gc.GoalClass>[];
//There will be one Settings object per app.
Settings? settings;
bool firstTimeFlag = false;

Future<List<gc.GoalClass>?> readAddGoals() async {
  FileIO reader = FileIO();

  void readInGoal(File file) async {
    String jsonContents = await reader.readInput(File(file.path));

    if (jsonContents.length != 0) {
      Map<String, dynamic> jsonGoal = jsonDecode(jsonContents);

      String begin = jsonGoal["begin"].toString().replaceAll(".", "-");
      String end = jsonGoal["end"].toString().replaceAll(".", "-");
      goalList.add(gc.GoalClass(DateTime.parse(begin), DateTime.parse(end),
          jsonGoal["percent"], jsonGoal["name"]));
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

      //further logic for settings...
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
    );
  }
}

class MyAppState extends ChangeNotifier {
  var goalList = <gc.GoalClass>[];
  var currGoal;
  bool editingMode = false;

  var appBarIndex = 0;
  var pageIndex = 0;

  gc.GoalClass addTestGoal() {
    gc.GoalClass goal =
        gc.GoalClass(DateTime.now(), DateTime.utc(2023, 12, 31), 0.69, "test");
    goalList.add(goal);
    goalList[0].updateMilestones(DateTime.now(), "test milestone");

    notifyListeners();
    return goal;
  }

  void testJson(gc.GoalClass goal) async {
    String path = await _localPath;
    FileIO reader = FileIO();

    reader.writeGoal(goal);
    //goal.readGoal();

    //log(Directory("$path").listSync().toString());
    //goalList[]
  }

  void addGoal(gc.GoalClass goal) {
    goalList.add(goal);
    notifyListeners();
  }
}

class Tracker extends StatefulWidget {
  @override
  State<Tracker> createState() => _Tracker();
}

class _Tracker extends State<Tracker> {
  @override
  void initState() {
    //readAddGoals();
  }

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
        FileIO writer = FileIO();
        gc.GoalClass goal = appState.addTestGoal();
        LocalNoticeService().addNotification(
          'Notification Title',
          'Notification Body',
          DateTime.now().millisecondsSinceEpoch + 5000,
          //The minimum time here seems to be 5 seconds afterward (5000)
          //Works even if the app is closed.
          channel: 'testing',
        );
        writer.writeGoal(goal);

        //appState.testJson(appState.goalList[0]);
      }),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        ListTile(
          title: Text("Notification Rate"),
          subtitle: Text(settings!.getRecurringTime().toString()),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    Dialog(child: Text("testing...")));
          },
        ),
        Divider(),
        ListTile(title: Text("Contact Us")),
        Divider(),
        ListTile(title: Text("About")),
      ],
    ));
  }
}

class AdjustSettings extends StatefulWidget {
  @override
  State<AdjustSettings> createState() => _AdjustSettings();
}

class _AdjustSettings extends State<AdjustSettings> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      child: Text("test"),
    );

    //return Scaffold(body: Text("testing..."),);
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
        appState.notifyListeners();
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

  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();

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
        gc.GoalClass goal = gc.GoalClass(begin, end, percent!, goalName);
        appState.goalList.add(goal);
        begin = null;
        end = null;
        goalName = null;
        percent = null;
      }
    }

    void _checkReady() {
      if (appState.editingMode ||
          (begin != null &&
              end != null &&
              goalName != null &&
              percent != null)) {
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
                _checkReady();
              });
            },
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _beginDateSelection();
                  _checkReady();
                });
              },
              child: Text(beginString),
            ),
            OutlinedButton(
                onPressed: () {
                  setState(() {
                    _endDateSelection();
                    _checkReady();
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
                _checkReady();
              });
            },
          ),
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
            FileIO deleter = FileIO();

            deleter.delete(appState.currGoal);
            appState.goalList.remove(appState.currGoal);
            appState.notifyListeners();
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
    Future<void> _addMilestoneDate() async {
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

    void _checkBools() {
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
                  _addMilestoneDate();
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
                        _checkBools();
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
