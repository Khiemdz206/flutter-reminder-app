import 'package:flutter/material.dart';
import 'package:khiem_dz_it2_app/note_model.dart'; // BƯỚC 1: IMPORT NOTE MODEL
import 'package:shared_preferences/shared_preferences.dart';

class DeletedNoteScreen extends StatefulWidget {
  const DeletedNoteScreen({super.key});

  @override
  State<DeletedNoteScreen> createState() => _DeletedNoteScreenState();
}

class _DeletedNoteScreenState extends State<DeletedNoteScreen> {
  // BƯỚC 2: THAY ĐỔI KIỂU DỮ LIỆU CỦA STATE
  List<Note> _deletedNotes = []; // <-- Từ List<String> thành List<Note>

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
  }

  // BƯỚC 3: CẬP NHẬT HÀM TẢI DỮ LIỆU
  Future<void> _loadDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    // Đọc danh sách chuỗi JSON
    final deletedNotesData = prefs.getStringList('deletedNotes') ?? [];
    setState(() {
      // Chuyển đổi mỗi chuỗi JSON thành một đối tượng Note
      _deletedNotes = deletedNotesData
          .map((noteJson) => Note.fromJson(noteJson))
          .toList();
    });
  }

  // BƯỚC 4: CẬP NHẬT HÀM KHÔI PHỤC
  Future<void> _restoreNote(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy danh sách ghi chú chính ra và chuyển đổi chúng
    final notesData = prefs.getStringList('notes') ?? [];
    List<Note> currentNotes = notesData.map((n) => Note.fromJson(n)).toList();

    // Xóa ghi chú khỏi danh sách đã xóa và thêm vào danh sách chính
    final noteToRestore = _deletedNotes.removeAt(index);
    currentNotes.add(noteToRestore);

    // Lưu cả hai danh sách đã cập nhật (chuyển đổi ngược lại thành JSON)
    await prefs.setStringList('notes', currentNotes.map((n) => n.toJson()).toList());
    await prefs.setStringList('deletedNotes', _deletedNotes.map((n) => n.toJson()).toList());
    
    // Cập nhật lại giao diện
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã khôi phục ghi chú "${noteToRestore.title}"')),
    );
  }

  // BƯỚC 5: CẬP NHẬT HÀM XÓA VĨNH VIỄN
  Future<void> _deleteForever(int index) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Chỉ cần xóa khỏi danh sách hiện tại
    _deletedNotes.removeAt(index);

    // Lưu lại danh sách đã xóa (đã được cập nhật)
    await prefs.setStringList('deletedNotes', _deletedNotes.map((n) => n.toJson()).toList());
    
    // Cập nhật giao diện
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thùng rác')),
      body: _deletedNotes.isEmpty
          ? const Center(child: Text('Không có ghi chú nào trong thùng rác.'))
          : ListView.builder(
              itemCount: _deletedNotes.length,
              itemBuilder: (context, index) {
                // BƯỚC 6: CẬP NHẬT GIAO DIỆN
                final note = _deletedNotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Bo tròn các góc
                  ),
                // Lấy ra đối tượng Note
                child: ListTile(
                  title: note.title.trim().isNotEmpty
                  ? Text(
                    note.title.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold), // In đậm tiêu đề
                  )
                  : null,
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ), 
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () => _restoreNote(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                        onPressed: () => _deleteForever(index),
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
    );
  }
}