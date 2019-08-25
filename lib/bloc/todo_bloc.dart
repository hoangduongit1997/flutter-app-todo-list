import 'dart:async';
import 'dart:math';
import 'package:flutter_app_todo/base/base_bloc.dart';
import 'package:flutter_app_todo/base/base_event.dart';
import 'package:flutter_app_todo/db/todo_table.dart';
import 'package:flutter_app_todo/repo/todo_repo.dart';
import 'package:flutter_app_todo/service/todo_service.dart';

import '../event/add_todo_event.dart';
import '../event/delete_todo_event.dart';
import '../model/todo.dart';

class TodoBloc extends BaseBloc {
  TodoRepo _todoRepo = TodoRepo();

  StreamController<List<Todo>> _todoListStreamController =
      StreamController<List<Todo>>();
  Stream<List<Todo>> get todoListStream => _todoListStreamController.stream;

  var _randomInt = Random();
  List<Todo> _todoListData = List<Todo>();

  initData() async {
    var data = await _todoRepo.initData();
    _todoListStreamController.sink.add(data);
  }

  _addTodo(Todo todo) async {
    // insert to database
    await _todoRepo.insertTodo(todo);

    _todoListData.add(todo);
    _todoListStreamController.sink.add(_todoListData);
  }

  _deleteTodo(Todo todo) async {
    await _todoRepo.deleteTodo(todo);

    _todoListData.remove(todo);
    _todoListStreamController.sink.add(_todoListData);
  }

  @override
  void dispatchEvent(BaseEvent event) {
    if (event is AddTodoEvent) {
      Todo todo = Todo.fromData(
        _randomInt.nextInt(1000000),
        event.content,
      );
      _addTodo(todo);
    } else if (event is DeleteTodoEvent) {
      _deleteTodo(event.todo);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _todoListStreamController.close();
  }
}
