import 'package:booking_group_flutter/features/groups/presentation/pages/groups_list_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/group_ideas_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_info_card.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/members_section.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyGroupDetailPage extends StatefulWidget {
  const MyGroupDetailPage({super.key});

  @override
  State<MyGroupDetailPage> createState() => _MyGroupDetailPageState();
}

class _MyGroupDetailPageState extends State<MyGroupDetailPage> {
  final MyGroupApi _myGroupApi = MyGroupApi();

  MyGroup? _myGroup;
  List<GroupMember> _members = [];
  UserProfile? _leader;
  bool _isLoading = true;
  String? _error;
  bool _isLeader = false;
  bool _isPerformingAction = false;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _loadGroupData();
  }

  Future<void> _loadGroupData({int retryCount = 0}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final myGroup = await _myGroupApi.getMyGroup();

      if (myGroup == null) {
        setState(() {
          _myGroup = null;
          _members = [];
          _leader = null;
          _isLeader = false;
        });
        return;
      }

      final results = await Future.wait([
        _myGroupApi.getGroupMembers(myGroup.id),
        _myGroupApi.getGroupLeader(myGroup.id),
      ]);

      setState(() {
        _myGroup = myGroup;
        _members = results[0] as List<GroupMember>;
        _leader = results[1] as UserProfile?;
        final leaderEmail = _leader?.email.toLowerCase();
        _isLeader = leaderEmail != null &&
            _currentUserEmail != null &&
            leaderEmail == _currentUserEmail!.toLowerCase();
      });
    } catch (e) {
      // Retry once if it's a 500 error and we haven't retried yet
      if (e.toString().contains('500') && retryCount < 2) {
        print(
          '⚠️ Got 500 error, retrying in 2 seconds... (attempt ${retryCount + 1}/2)',
        );
        await Future.delayed(const Duration(seconds: 2));
        return _loadGroupData(retryCount: retryCount + 1);
      }

      setState(() {
        _error = e.toString();
        _isLeader = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToIdeasPage() {
    if (_myGroup == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupIdeasPage(groupId: _myGroup!.id, leader: _leader),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Bạn chưa tham gia nhóm nào',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Hãy tham gia một nhóm để bắt đầu\nlàm việc cùng các thành viên khác',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupsListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Xem danh sách nhóm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadGroupData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _navigateToIdeasPage,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF8B5CF6),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ý tưởng của nhóm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Xem và quản lý ý tưởng',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhóm của bạn'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myGroup == null
          ? _buildEmptyState()
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadGroupData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GroupInfoCard(
                      group: _myGroup!,
                      memberCount: _members.length,
                      showLeaderActions: _isLeader,
                      actionsEnabled: !_isPerformingAction,
                      onEditInfo: _isLeader ? _handleEditGroupInfo : null,
                      onToggleType:
                          _isLeader ? _handleToggleGroupType : null,
                      onCompleteGroup:
                          _isLeader ? _handleCompleteGroup : null,
                    ),
                    const SizedBox(height: 24),
                    MembersSection(
                      members: _members,
                      leader: _leader,
                      currentUserEmail: _currentUserEmail,
                    ),
                    const SizedBox(height: 24),
                    _buildIdeasCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleEditGroupInfo() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final updatedValues = await _showEditGroupDialog(group);
    if (updatedValues == null) {
      return;
    }

    await _performGroupAction(
      () => _myGroupApi.updateGroupInfo(
        groupId: group.id,
        title: updatedValues['title']!,
        description: updatedValues['description']!,
      ),
      successMessage: 'Đã cập nhật thông tin nhóm',
    );
  }

  Future<void> _handleToggleGroupType() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final currentType = group.type.toUpperCase();
    final nextType = currentType == 'PUBLIC' ? 'PRIVATE' : 'PUBLIC';
    final confirmed = await _showConfirmationDialog(
      title: 'Thay đổi trạng thái nhóm',
      message:
          'Bạn có chắc muốn chuyển nhóm sang chế độ ${nextType == 'PUBLIC' ? 'Công khai' : 'Riêng tư'}?',
      confirmLabel: 'Xác nhận',
    );

    if (confirmed != true) {
      return;
    }

    await _performGroupAction(
      () => _myGroupApi.changeGroupType(),
      successMessage:
          'Đã chuyển trạng thái nhóm sang ${nextType == 'PUBLIC' ? 'Công khai' : 'Riêng tư'}',
    );
  }

  Future<void> _handleCompleteGroup() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Hoàn tất nhóm',
      message:
          'Khi hoàn tất, nhóm sẽ không thể thay đổi thành viên nữa. Bạn có chắc chắn?',
      confirmLabel: 'Hoàn tất',
    );

    if (confirmed != true) {
      return;
    }

    await _performGroupAction(
      () => _myGroupApi.completeGroup(),
      successMessage: 'Nhóm đã được đánh dấu hoàn tất',
    );
  }

  Future<void> _performGroupAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      await action();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );

      await _loadGroupData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<Map<String, String>?> _showEditGroupDialog(MyGroup group) async {
    final titleController = TextEditingController(text: group.title);
    final descriptionController =
        TextEditingController(text: group.description);
    String? errorMessage;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Cập nhật thông tin nhóm'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhóm',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả nhóm',
                      ),
                      maxLines: 4,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty) {
                      setStateDialog(() {
                        errorMessage = 'Tên nhóm không được để trống';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'title': title,
                      'description': description,
                    });
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}
