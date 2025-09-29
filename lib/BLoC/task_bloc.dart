import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';

class Task {
  final String id;
  final String title;

  Task({required this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'title': title};
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
    );
  }
}

class TaskState {
  final List<Task> tasks;
  final bool isLoading;

  const TaskState({this.tasks = const [], this.isLoading = false});
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TaskBloc() : super(const TaskState()) {
    on<AddTaskEvent>((event, emit) async {
      try {
        // Añadir la tarea a Firebase
        await _firestore.collection('tasks').add({
          'title': event.title,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Recargar las tareas
        add(LoadTasksEvent());
      } catch (e) {
        print('Error adding task: $e');
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      try {
        await _firestore.collection('tasks').doc(event.taskId).delete();

        // Actualizar el estado local inmediatamente
        final updatedTasks = state.tasks.where((task) => task.id != event.taskId).toList();
        emit(TaskState(tasks: updatedTasks));
      } catch (e) {
        print('Error deleting task: $e');
      }
    });

    on<LoadTasksEvent>((event, emit) async {
      try {
        emit(TaskState(tasks: state.tasks, isLoading: true));

        final snapshot = await _firestore
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .get();

        final tasks = snapshot.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList();

        emit(TaskState(tasks: tasks, isLoading: false));
      } catch (e) {
        print('Error loading tasks: $e');
        emit(TaskState(tasks: state.tasks, isLoading: false));
      }
    });
  }
}