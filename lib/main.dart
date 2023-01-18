import 'package:percent_indicator/percent_indicator.dart' as perc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'GoalClass.dart' as gc;

void main() {
  runApp(MyApp());
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

  var appBarIndex = 0;
  var pageIndex = 0;

  void addTestGoal() {
    goalList.add(
        gc.GoalClass(DateTime.now(), DateTime.utc(2023, 12, 31), 0.69, "test"));
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
    //appState.pageIndex = appState.appBarIndex;
    switch (appState.pageIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ManagePage();
        break;
      case 2:
        page = Placeholder();
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
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
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
    var goals = appState.goalList;
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
                return ListTile(
                  onTap: () {
                    appState.currGoal = goal;
                    print(appState.currGoal);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GoalEditPage()),
                    );
                  },
                  minVerticalPadding: 2,
                  tileColor: Color.fromARGB(255, 78, 167, 118),
                  title: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${goal.name}"),
                            Text("${goal.getStringPercent()}%"),
                          ]),
                      perc.LinearPercentIndicator(
                        percent: goal.percent!.toDouble(),
                        backgroundColor: Colors.grey,
                        progressColor: Colors.blue,
                      ),
                    ],
                  ),
                  subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${goal.begin!.month}/${goal.begin!.day}/${goal.begin!.year}",
                        ),
                        Text(" "),
                        Text(
                          "${goal.end!.month}/${goal.end!.day}/${goal.end!.year}",
                        ),
                      ]),
                );
              }),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        appState.addTestGoal();
      }),
    );
  }
}

class ManagePage extends StatefulWidget {
  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  @override
  Widget build(BuildContext ctx) {
    var appState = ctx.watch<MyAppState>();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalCreatorPage()),
        );
      },
      child: Icon(Icons.add),
    ));
  }
}

class GoalCreatorPage extends StatefulWidget {
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

  Future<Null> _beginDateSelection() async {
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

  Future<Null> _endDateSelection() async {
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

    void addGoal() {
      gc.GoalClass goal = gc.GoalClass(begin, end, percent, goalName);
      appState.goalList.add(goal);
      begin = null;
      end = null;
      goalName = null;
      percent = null;
    }

    void _checkReady() {
      if (begin != null && end != null && goalName != null && percent != null) {
        confirmReady = true;
      } else {
        confirmReady = false;
      }
    }

    return Scaffold(
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
                        addGoal();
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
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditGoalPage()));
                },
                child: Text("Edit Goal")),
            OutlinedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GoalCreatorPage()));
                },
                child: Text("Delete Goal")),
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

    if (appState.currGoal.milestones.isEmpty) {
      msg = "No milestones yet";
    }

    void _displayMilestones() {}

    return Scaffold(
        body: ListView(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text(msg)),
      ),
      for (var entry in appState.currGoal.milestones.entries)
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
      print(appState.currGoal.milestones);
    }

    void _checkBools() {
      if (dateBool && textBool) {
        confirmBool = true;
      }
    }

    return Scaffold(
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

class EditGoalPage extends StatefulWidget {
  @override
  _EditGoalPageState createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold();
  }
}
