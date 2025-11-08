import 'package:flutter/cupertino.dart'; // Thay thế material.dart bằng cupertino.dart
import 'package:flutter/material.dart'; // Giữ lại để dùng cho Navigator (tùy chọn)
import 'package:khiem_dz_it2_app/screens/note_detail_screen.dart';
import 'screens/note_list_screen.dart';
import 'screens/deleted_notes.dart';
import 'screens/reminder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>{
  int _noteCount = 0;
  int _noteDeleted = 0;
  


  @override
  void initState(){
    super.initState();
    _loadNoteCount();
    _loadNoteDeleted();
  }


  
  Future<void> _loadNoteCount() async {
    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getStringList('notes') ?? [];

    setState (() {
      _noteCount = notes.length;
    }

    );
  }

  Future<void> _loadNoteDeleted() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedNotes = prefs.getStringList('deletedNotes') ?? [];

    setState((){
      _noteDeleted = deletedNotes.length;
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng CupertinoPageScaffold thay cho Scaffold
    return CupertinoPageScaffold(
      // Sử dụng CupertinoSliverNavigationBar để có hiệu ứng tiêu đề lớn
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Folders'), // Tiêu đề lớn giống iOS
          ),
          // Phần thân của màn hình nằm trong Sliver
          SliverFillRemaining(
            child: Column(
              children: [
                // Thanh tìm kiếm
                // Expanded để danh sách chiếm hết không gian còn lại
                Expanded(
                  child: ListView(
                    children: [
                      // Sử dụng CupertinoListSection để nhóm các mục
                      CupertinoListSection.insetGrouped(
                        header: const Text('iCloud'),
                        children: <Widget>[
                          // Sử dụng CupertinoListTile thay cho ListTile
                          CupertinoListTile(
                            title: const Text('Ghi chú'),
                            leading: const Icon(CupertinoIcons.folder_solid, color: CupertinoColors.systemYellow),
                            additionalInfo: Text(_noteCount.toString()), // Hiển thị số lượng
                            trailing: const CupertinoListTileChevron(), // Mũi tên chỉ hướng của iOS
                            onTap:  () async {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => const NoteListScreen()),
                              );
                              _loadNoteCount();
                              _loadNoteDeleted();
                            },
                          ),
                          CupertinoListTile(
                            title: const Text('Thùng rác'),
                            leading: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.systemGrey),
                            additionalInfo:  Text(_noteDeleted.toString()),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => const DeletedNoteScreen()),
                              );
                              
                              _loadNoteDeleted();
                              _loadNoteCount();
                            },
                          ),
                          CupertinoListTile(
                            title: const Text('Lời nhắc'),
                            leading: const Icon(CupertinoIcons.bell_fill, color: CupertinoColors.systemRed),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => const SimpleReminderScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Thanh công cụ ở dưới cùng
                Container(
                  padding: const EdgeInsets.only(bottom: 20, right: 10),
                  decoration: const BoxDecoration(
                     border: Border(top: BorderSide(color: CupertinoColors.separator, width: 0.5))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Icon(CupertinoIcons.square_pencil),
                        onPressed: () async {
                          final result = await Navigator.push(
                                context,
      // Nên dùng CupertinoPageRoute để đồng bộ hiệu ứng chuyển cảnh
                                CupertinoPageRoute(builder: (context) => const NoteDetailScreen()),
                                );

    // BƯỚC 1: Kiểm tra xem kết quả trả về có phải là một đối tượng Note không
                                if (result != null) {
                                final prefs = await SharedPreferences.getInstance();

      // BƯỚC 2: Lấy danh sách các chuỗi JSON hiện tại
                                final currentNotes = prefs.getStringList('notes') ?? [];
      
      // BƯỚC 3: Chuyển đổi đối tượng Note mới thành chuỗi JSON và thêm vào danh sách
                                currentNotes.add(result.toJson());

      // BƯỚC 4: Lưu lại danh sách đã cập nhật
                                await prefs.setStringList('notes', currentNotes);

      // BƯỚC 5: Tải lại số lượng để cập nhật giao diện
                                _loadNoteCount();
                           }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}