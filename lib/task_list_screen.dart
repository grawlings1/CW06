import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cw06/task.dart';
import 'auth_service.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _addTask(String taskName) async {
    if (taskName.trim().isEmpty) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
      'name': taskName,
      'isCompleted': false,
      'subTasks': []
    });
    _taskController.clear();
  }

  Future<void> _toggleTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});
  }

  Future<void> _deleteTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .delete();
  }

  Future<void> _addSubTask(Task task, String subTaskText) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({
      'subTasks': FieldValue.arrayUnion([subTaskText])
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference tasksRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
              })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                        labelText: 'Enter task', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTask(_taskController.text),
                  child: Text('Add'),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                List<Task> tasks = snapshot.data!.docs.map((doc) {
                  return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      Task task = tasks[index];
                      return TaskCard(
                        task: task,
                        toggleTask: _toggleTask,
                        deleteTask: _deleteTask,
                        addSubTask: _addSubTask,
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(Task) toggleTask;
  final Function(Task) deleteTask;
  final Function(Task, String) addSubTask;

  TaskCard({
    required this.task,
    required this.toggleTask,
    required this.deleteTask,
    required this.addSubTask,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TextEditingController _subTaskController = TextEditingController();

  Widget _buildSubTasks() {
    if (widget.task.subTasks.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: widget.task.subTasks
            .map((subTask) => ListTile(
                  title: Text(subTask),
                  dense: true,
                ))
            .toList(),
      ),
    );
  }

  void _handleAddSubTask() {
    final subTaskText = _subTaskController.text.trim();
    if (subTaskText.isEmpty) return;
    widget.addSubTask(widget.task, subTaskText);
    _subTaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: widget.task.isCompleted,
              onChanged: (value) => widget.toggleTask(widget.task),
            ),
            Expanded(
              child: Text(
                widget.task.name,
                style: TextStyle(
                  decoration: widget.task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => widget.deleteTask(widget.task),
            )
          ],
        ),
        children: [
          _buildSubTasks(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskController,
                    decoration: InputDecoration(
                      labelText: 'Add sub task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleAddSubTask,
                  child: Text('Add'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
