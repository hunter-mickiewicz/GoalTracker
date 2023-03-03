import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:goal_tracker/GoalClass.dart';
import 'package:path_provider/path_provider.dart';

class FileIO {
  FileIO() {}

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(GoalClass goal) async {
    String fileName = goal.updateFileName();
    final path = await _localPath;
    return File('$path/$fileName.txt');
  }

  Future<File> writeGoal(GoalClass goal) async {
    final file = await _localFile(goal);

    Map<String, dynamic> JSONContent = goal.toJson();

    return file.writeAsString(jsonEncode(JSONContent));
  }

  Future<String> readGoal(File file) async {
    try {
      final contents = await file.readAsString();

      return contents;
    } catch (error) {
      return "";
    }
  }

  void delete(GoalClass goal) async {
    File file = await _localFile(goal);
    log(file.toString());
    file.delete();
  }
}
