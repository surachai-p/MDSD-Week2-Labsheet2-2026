import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 02 Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Main Screen with Bottom Navigation ─────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CounterPage(),
    FormPage(),
    TodoPage(), // เพิ่มหน้า Todo สำหรับโจทย์ D
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Counter'),
          NavigationDestination(icon: Icon(Icons.edit), label: 'Form'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Todo'), // เพิ่มเมนู Todo
        ],
      ),
    );
  }
}

// ─── Page 1: Dashboard ──────────────────────────────────
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClockWidget(),
            SizedBox(height: 16),
            Text('ข้อมูลสรุป',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InfoCard(
              title: 'นักศึกษา', value: '42 คน',
              icon: Icons.people, color: Colors.indigo,
            ),
            SizedBox(height: 8),
            InfoCard(
              title: 'GPA เฉลี่ย', value: '3.21',
              icon: Icons.school, color: Colors.green,
            ),
            SizedBox(height: 8),
            InfoCard(
              title: 'รายวิชา', value: '5 วิชา',
              icon: Icons.book, color: Colors.orange,
            ),
            SizedBox(height: 8),
            InfoCard(
              title: 'คณะ', value: 'วิทยาศาสตร์',
              icon: Icons.account_balance, color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 2: Counter ────────────────────────────────────
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const CounterSection(),
    );
  }
}

// ─── Page 3: Form (แก้ไขตามโจทย์ C) ───────────────────────
class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างคำทักทาย'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const GreetingForm(),
    );
  }
}

// ─── Page 4: Todo (สร้างใหม่ตามโจทย์ D) ─────────────────────
class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const TodoSection(),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ClockWidget (StatefulWidget) ───────────────────────

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.access_time, size: 32, color: Colors.indigo),
              Text(
                '${_pad(_currentTime.hour)}:${_pad(_currentTime.minute)}:${_pad(_currentTime.second)}',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Text('${_currentTime.day}/${_currentTime.month}/${_currentTime.year + 543}',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CounterSection (StatefulWidget) ────────────────────

class CounterSection extends StatefulWidget {
  const CounterSection({super.key});

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  int _count = 0;
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_count',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: _count >= 0 ? Colors.indigo : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'dec',
                onPressed: () => setState(() => _count -= _step),
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.remove, color: Colors.red),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => setState(() => _count = 0),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'inc',
                onPressed: () => setState(() => _count += _step),
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.add, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Step:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 5, 10, 100].map((s) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('$s'),
                selected: _step == s,
                onSelected: (_) => setState(() => _step = s),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── GreetingForm (StatefulWidget - อัปเดตโจทย์ C) ────────

class GreetingForm extends StatefulWidget {
  const GreetingForm({super.key});

  @override
  State<GreetingForm> createState() => _GreetingFormState();
}

class _GreetingFormState extends State<GreetingForm> {
  final _nameController = TextEditingController();
  String _greeting = '';
  String _error = '';
  
  // ตัวแปรสำหรับโจทย์ C: เก็บภาษาที่เลือก
  String _selectedLang = 'ไทย';
  final List<String> _languages = ['ไทย', 'English', '日本語'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    setState(() {
      if (name.isEmpty) {
        _error = 'กรุณากรอกชื่อ';
        _greeting = '';
      } else {
        _error = '';
        final h = DateTime.now().hour;
        String periodText = '';
        String welcomeText = '';
        
        // กำหนดคำทักทายตามภาษา (โจทย์ C)
        if (_selectedLang == 'ไทย') {
          periodText = h < 12 ? 'ตอนเช้า' : h < 17 ? 'ตอนบ่าย' : 'ตอนเย็น';
          welcomeText = 'สวัสดี$periodText คุณ$name! 👋\nยินดีต้อนรับสู่ Flutter';
        } else if (_selectedLang == 'English') {
          periodText = h < 12 ? 'Morning' : h < 17 ? 'Afternoon' : 'Evening';
          welcomeText = 'Good $periodText, $name! 👋\nWelcome to Flutter';
        } else {
          periodText = h < 12 ? 'おはようございます' : h < 17 ? 'こんにちは' : 'こんばんは';
          welcomeText = '$periodText, $name さん! 👋\nFlutterへようこそ';
        }

        _greeting = welcomeText;
      }
    });
  }

  void _clear() {
    _nameController.clear();
    setState(() {
      _greeting = '';
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Widget สำหรับโจทย์ C: Dropdown เลือกภาษา
          DropdownButtonFormField<String>(
            value: _selectedLang,
            decoration: const InputDecoration(
              labelText: 'ภาษา (Language)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.language),
            ),
            items: _languages.map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedLang = val);
                // ถ้ามีชื่ออยู่แล้ว ให้สร้างคำทักทายใหม่ทันทีที่เปลี่ยนภาษา
                if (_nameController.text.isNotEmpty) _submit();
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อของคุณ',
              hintText: 'เช่น สมชาย',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              errorText: _error.isEmpty ? null : _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.waving_hand),
                  label: const Text('สร้างคำทักทาย'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _clear,
                child: const Text('ล้าง'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_greeting.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Text(
                _greeting,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── TodoSection (StatefulWidget - สร้างใหม่สำหรับโจทย์ D) ──
class TodoItem {
  String task;
  bool isDone;
  TodoItem({required this.task, this.isDone = false});
}

class TodoSection extends StatefulWidget {
  const TodoSection({super.key});

  @override
  State<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  final _todoController = TextEditingController();
  final List<TodoItem> _todos = [];

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos.add(TodoItem(task: text));
        _todoController.clear();
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int remaining = _todos.where((t) => !t.isDone).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่องาน',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'งานที่ต้องทำ: $remaining งาน',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Text('ไม่มีงานในรายการ 🎉',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final item = _todos[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isDone,
                            onChanged: (_) => _toggleTodo(index),
                          ),
                          title: Text(
                            item.task,
                            style: TextStyle(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isDone ? Colors.grey : Colors.black,
                            ),
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
}
