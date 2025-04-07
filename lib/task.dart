class Task {
  final String id;
  final String name;
  final bool isCompleted;
  final List<String> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks = const [],
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      subTasks: List<String>.from(data['subTasks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'subTasks': subTasks,
    };
  }
}
