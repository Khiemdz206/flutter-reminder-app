import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart'; 

class SimpleReminderScreen extends StatefulWidget {
  const SimpleReminderScreen({super.key});

  @override
  State<SimpleReminderScreen> createState() => _SimpleReminderScreenState();
}

class _SimpleReminderScreenState extends State<SimpleReminderScreen> {
  Map<String, List<String>> _events = {}; // key = "yyyy-mm-dd"
  DateTime _selectedDay = DateTime.now();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('simple_reminders');
    if (data != null) {
      setState(() {
        _events = Map<String, List<String>>.from(
          json.decode(data).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        );
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('simple_reminders', json.encode(_events));
  }

  List<String> _getEventsForDay(DateTime day) {
    final key = _formatDate(day);
    return _events[key] ?? [];
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm lời nhắc ngày ${_selectedDay.day}/${_selectedDay.month}"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Nhập nội dung..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (_controller.text.isEmpty) return;
              final key = _formatDate(_selectedDay);
              setState(() {
                _events.putIfAbsent(key, () => []).add(_controller.text);
              });
              _controller.clear();
              await _saveEvents();
              Navigator.pop(context);
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  // Hàm _deleteForever đã được sửa lại
  Future<void> _deleteEvent(int index) async {
    // 1. Lấy key của ngày đang được chọn
    final key = _formatDate(_selectedDay);

    // 2. Cập nhật trạng thái trong setState để giao diện thay đổi
    setState(() {
      // 3. Xóa sự kiện tại vị trí 'index' ra khỏi danh sách của ngày đó
      _events[key]?.removeAt(index);

      // 4. (Quan trọng) Nếu ngày đó không còn sự kiện nào, xóa luôn key đó khỏi map
    });

    // 5. Lưu lại toàn bộ map events vào bộ nhớ
    await _saveEvents();
  }


  @override
  Widget build(BuildContext context) {
    final eventsToday = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch & Lời nhắc"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'vi_VN',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (sel, foc) => setState(() => _selectedDay = sel),
            eventLoader: (day) => _getEventsForDay(day),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          const Divider(),
          Expanded(
            child: eventsToday.isEmpty
                ? const Center(child: Text("Không có lời nhắc nào"))
                : ListView.builder(
                    itemCount: eventsToday.length,
                    itemBuilder: (context, i) {
                      final e = eventsToday[i];
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(e),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteEvent(i),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
