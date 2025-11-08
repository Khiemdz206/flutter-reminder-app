import 'package:flutter/material.dart';
import 'package:khiem_dz_it2_app/note_model.dart'; // Import model

class NoteDetailScreen extends StatefulWidget {
  // Thay đổi constructor để nhận một đối tượng Note (có thể null)
  final Note? note;
  const NoteDetailScreen({super.key, this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // Hai controller cho hai ô nhập liệu
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Nếu là sửa note, điền thông tin cũ vào
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void _saveNote() {
    // Kiểm tra xem tiêu đề hoặc nội dung có được nhập không
    if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
      // Tạo một đối tượng Note mới từ dữ liệu người dùng nhập
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
      );
      // Gửi đối tượng Note này về màn hình trước
      Navigator.pop(context, newNote);
    } else {
      // Nếu không nhập gì thì chỉ quay về
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          // Nút lưu
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô nhập tiêu đề
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tiêu đề',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Ô nhập nội dung
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Nội dung',
                  border: InputBorder.none,
                ),
                maxLines: null, // Cho phép xuống dòng vô hạn
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}