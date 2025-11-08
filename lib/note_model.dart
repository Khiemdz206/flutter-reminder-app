import 'dart:convert';

class Note {
  // 1. Thêm thuộc tính 'id'. Dùng 'final' vì id không nên thay đổi sau khi được tạo.
  final String id;
  String title;
  String content;

  // 2. Cập nhật constructor để xử lý 'id'
  Note({
    String? id, // id là tùy chọn, nếu không có, ta sẽ tự tạo
    required this.title,
    required this.content,
    // Nếu id được truyền vào thì dùng, nếu không thì tạo một id mới duy nhất dựa trên thời gian
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // 3. Cập nhật toMap để bao gồm 'id' khi lưu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  // 4. Cập nhật fromMap để đọc 'id' khi tải
  // Factory constructor này sẽ được dùng để tạo một đối tượng Note từ dữ liệu đã lưu
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      // Đọc 'id' từ map. Nếu không có (với các ghi chú cũ đã lưu),
      // constructor ở trên sẽ tự động tạo một id mới.
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }

  // Các hàm tiện ích này không cần thay đổi vì chúng gọi toMap và fromMap
  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}