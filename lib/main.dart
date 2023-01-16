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

  var appBarIndex = 0;
  var pageIndex = 0;

  void addGoal(DateTime start, DateTime end, double perc) {
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

    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(msg)),
        ),
        for (var goal in goals)
          Card(
            child: ListTile(
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
              //Text("${goal.begin!.month}/${goal.begin!.day}/${goal.begin!.year}    ${goal.end!.month}/${goal.end!.day}/${goal.end!.year}"),
            ),
          ),
      ],
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
      beginString = "${begin!.month}/${begin!.day}/${begin!.year}";
    });
  }

  Future<Null> _endDateSelection() async {
    end = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    setState(() {
      endString = "${end!.month}/${end!.day}/${end!.year}";
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

          //Error here on textfield and textformfield..

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
