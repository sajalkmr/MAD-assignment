import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Todo item class
class Todo {
  String text;
  bool isDone;
  DateTime createdAt;

  Todo({
    required this.text,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    text: json['text'],
    isDone: json['isDone'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadTodos();
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodos() async {
    if (_prefs == null) return;
    
    try {
      final todosJson = _prefs!.getStringList('todos') ?? [];
      setState(() {
        _todos.clear();
        _todos.addAll(
          todosJson.map((item) => Todo.fromJson(jsonDecode(item))).toList(),
        );
      });
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> _saveTodos() async {
    if (_prefs == null) return;
    
    try {
      final todosJson = _todos
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await _prefs!.setStringList('todos', todosJson);
    } catch (e) {
      debugPrint('Error saving todos: $e');
    }
  }

  void _addTodo() {
    if (_textController.text.trim().isEmpty) return;
    
    setState(() {
      _todos.add(Todo(text: _textController.text.trim()));
      _textController.clear();
    });
    _saveTodos();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
    _saveTodos();
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Enter a todo item',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _addTodo(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: _addTodo,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (_) => _toggleTodo(index),
                          ),
                          title: Text(
                            todo.text,
                            style: TextStyle(
                              decoration: todo.isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            'Created: ${todo.createdAt.toString().split('.')[0]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTodo(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
