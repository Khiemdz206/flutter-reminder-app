import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:khiem_dz_it2_app/note_model.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];
  List<Note> _deletedNotes = [];
  // Danh sách mới để giữ các ghi chú được lọc
  List<Note> _filteredNotes = [];
  // Controller cho thanh tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    // Thêm một listener để lắng nghe các thay đổi trong thanh tìm kiếm
    _searchController.addListener(_filterNotes);
  }

  // Giải phóng controller khi widget bị hủy
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final notesData = prefs.getStringList('notes') ?? [];
      _notes = notesData.map((noteJson) => Note.fromJson(noteJson)).toList();
      // Ban đầu, hiển thị tất cả các ghi chú
      _filteredNotes = _notes;

      final deletedNotesData = prefs.getStringList('deletedNotes') ?? [];
      _deletedNotes = deletedNotesData.map((noteJson) => Note.fromJson(noteJson)).toList();
    });
  }

  Future<void> _saveNotes() async {
      final prefs = await SharedPreferences.getInstance();
      final notesData = _notes.map((note) => note.toJson()).toList();
      await prefs.setStringList('notes', notesData);

      final deletedNotesData = _deletedNotes.map((note) => note.toJson()).toList();
      await prefs.setStringList('deletedNotes', deletedNotesData);
  }

  Future<void> _deleteNote(int index) async {
    setState(() {
      // Tìm ghi chú gốc trong danh sách _notes và xóa nó
      final noteToDelete = _filteredNotes[index];
      final originalIndex = _notes.indexWhere((note) => note.id == noteToDelete.id);
      if (originalIndex != -1) {
        final deleted = _notes.removeAt(originalIndex);
        _deletedNotes.add(deleted);
      }
      // Cập nhật lại danh sách đã lọc
      _filterNotes();
    });
    await _saveNotes();
  }

  // Hàm để lọc các ghi chú
  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = note.content.toLowerCase().contains(query);
        // Trả về true nếu tiêu đề hoặc nội dung khớp với truy vấn
        return titleMatch || contentMatch;
      }).toList();
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú của bạn'),
        // Thêm thanh tìm kiếm vào cuối AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      // Sử dụng _filteredNotes thay vì _notes
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('Không tìm thấy ghi chú nào.'))
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return ListTile(
                  title: Text(
                       note.title.trim().isNotEmpty ? note.title : note.content,
                    ),
                  subtitle: Text(
                          note.title.trim().isNotEmpty ? note.content : "",
                           maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    // Tìm chỉ mục gốc của ghi chú trong danh sách _notes
                    final originalIndex = _notes.indexWhere((n) => note.id == note.id);
                    if (originalIndex == -1) return;

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note),
                      ),
                    );
                    if (result != null && result is Note) {
                      setState(() {
                        _notes[originalIndex] = result;
                        // Cập nhật lại danh sách đã lọc
                        _filterNotes();
                      });
                      await _saveNotes();
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const NoteDetailScreen(),
            ),
          );
          if (result != null && result is Note) {
            setState(() {
              _notes.add(result);
              // Cập nhật lại danh sách đã lọc
              _filterNotes();
            });
            await _saveNotes();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo ghi chú mới',
      ),
    );
  }
}