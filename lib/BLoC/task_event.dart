import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddTaskEvent extends TaskEvent {
  final String title;

  AddTaskEvent(this.title);

  @override
  List<Object> get props => [title];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class LoadTasksEvent extends TaskEvent {}