import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/save_task.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTaskCard(
    BuildContext context,
    task,
    int index,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [const Color(0xFF2D4A3E), const Color(0xFF1E3A2E)]
                : [const Color(0xFF1E3A5F), const Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isCompleted
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    context.read<SaveTask>().checkTask(index);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<SaveTask>().removeTask(task);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFF6584),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Ongoing'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Finished'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-todo-screen');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        elevation: 6,
      ),
      body: Consumer<SaveTask>(
        builder: (context, taskProvider, child) {
          final ongoingTasks = taskProvider.tasks
              .asMap()
              .entries
              .where((entry) => !entry.value.isCompleted)
              .toList();

          final finishedTasks = taskProvider.tasks
              .asMap()
              .entries
              .where((entry) => entry.value.isCompleted)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Ongoing Tasks Tab
              ongoingTasks.isEmpty
                  ? _buildEmptyState(
                      'No ongoing tasks!\nTap + to add one',
                      Icons.task_alt,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80),
                      itemCount: ongoingTasks.length,
                      itemBuilder: (context, listIndex) {
                        final entry = ongoingTasks[listIndex];
                        final actualIndex = entry.key;
                        final task = entry.value;
                        return _buildTaskCard(
                          context,
                          task,
                          actualIndex,
                          false,
                        );
                      },
                    ),

              // Finished Tasks Tab
              finishedTasks.isEmpty
                  ? _buildEmptyState(
                      'No completed tasks yet',
                      Icons.check_circle,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80),
                      itemCount: finishedTasks.length,
                      itemBuilder: (context, listIndex) {
                        final entry = finishedTasks[listIndex];
                        final actualIndex = entry.key;
                        final task = entry.value;
                        return _buildTaskCard(context, task, actualIndex, true);
                      },
                    ),
            ],
          );
        },
      ),
    );
  }
}
