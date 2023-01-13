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

  var selectedIndex = 0;

  void addGoal(DateTime start, DateTime end, double perc) {
    goalList
        .add(gc.GoalClass(DateTime.now(), DateTime.utc(2023, 12, 31), 0.69));
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
    switch (appState.selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ManagePage();
        break;
      case 2:
        page = GoalCreatorPage();
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
        currentIndex: appState.selectedIndex,
        selectedItemColor: Color.fromARGB(255, 139, 12, 12),
        onTap: (index) {
          setState(() {
            appState.selectedIndex = index;
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
                  Text("${goal.getStringPercent()}%"),
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

    void _createGoal() {
      appState.selectedIndex = 2;
      appState.notifyListeners();
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
      onPressed: _createGoal,
      child: Icon(Icons.add),
    ));
  }
}

class GoalCreatorPage extends StatefulWidget {
  @override
  State<GoalCreatorPage> createState() => _GoalCreatorPageState();
}

class _GoalCreatorPageState extends State<GoalCreatorPage> {
  DateTime? begin;
  String beginString = "Select Start Date";
  DateTime? end;
  String endString = "Select End Date";

  void _dateSelection() {
    DialogRoute<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return DatePickerDialog(
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now(),
          );
        });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        body: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(
            onPressed: () {
              _dateSelection();
            },
            child: Text("Start Date"),
          ),
          OutlinedButton(onPressed: _dateSelection, child: Text("EndDate"))
        ]),
      ],
    ));
  }
}
