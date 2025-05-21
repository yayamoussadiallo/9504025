import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  List<_Todo> _todos = [];
  static const String _storageKey = 'todos';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_storageKey);
    if (todosString != null) {
      final List decoded = jsonDecode(todosString);
      setState(() {
        _todos = decoded.map((e) => _Todo.fromJson(e)).toList();
      });
    } else {
      // Valeurs par défaut si aucune sauvegarde
      setState(() {
        _todos = [
          _Todo('Achat de Television', true),
          _Todo('Facture Electricité', false),
          _Todo('Scolarité des Enfants', true),
          _Todo('Autre example  de Depenses', false),
          _Todo('Autre example  de Depenses', false),
        ];
      });
      _saveTodos();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString = jsonEncode(
      _todos.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, todosString);
  }

  void _showAddTaskModal() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Détails des Depenses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Entrez une courte description',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Montant',
                    hintText: 'Entrez le montant',
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _editingController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Entrez la date',
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller.clear();
                  _descriptionController.clear();
                  _contentController.clear();
                  _editingController.clear();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _todos.add(
                      _Todo(
                        text,
                        false,
                        description: _descriptionController.text.trim(),
                        content: _contentController.text.trim(),
                      ),
                    );
                  });
                  _saveTodos();
                  Navigator.pop(context);
                  _controller.clear();
                  _descriptionController.clear();
                  _contentController.clear();
                  _editingController.clear();
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  void _showTaskDetails(_Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(todo.text),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0.5,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todo.description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todo.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Montant',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[30],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            todo.content.isEmpty
                                ? 'Aucun contenu'
                                : todo.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[30],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            todo.content.isEmpty
                                ? 'Aucun contenu'
                                : todo.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      _todos[index].done = !_todos[index].done;
    });
    _saveTodos();
  }

  void _removeTask(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _todos.where((t) => !t.done).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les Dépenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Déconnexion',
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 5.5,
      ),
      backgroundColor: const Color(0xFFF3F5FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Saisir une Dépense ici',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _showAddTaskModal(),
                      ),
                    ),
                    Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _showAddTaskModal,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: _todos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return InkWell(
                        onTap: () => _showTaskDetails(todo),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: todo.done,
                                    onChanged: (_) => _toggleTask(index),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          todo.text,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            decoration:
                                                todo.done
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                            color:
                                                todo.done
                                                    ? Colors.grey
                                                    : Colors.black,
                                          ),
                                        ),
                                        if (todo.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            todo.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () => _removeTask(index),
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Il vous reste : $remaining depenses non éffectuer',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  ' Attention ! "Ne depensez pas ce que vous n avez pas" ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Todo {
  final String text;
  final String description;
  final String content;
  bool done;
  _Todo(this.text, this.done, {this.description = '', this.content = ''});

  Map<String, dynamic> toJson() => {
    'text': text,
    'description': description,
    'content': content,
    'done': done,
  };

  factory _Todo.fromJson(Map<String, dynamic> json) => _Todo(
    json['text'] as String,
    json['done'] as bool,
    description: json['description'] as String? ?? '',
    content: json['content'] as String? ?? '',
  );
}
