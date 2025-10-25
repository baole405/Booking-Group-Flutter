import 'package:booking_group_flutter/features/my_group/presentation/dialogs/create_idea_dialog.dart';
import 'package:booking_group_flutter/features/my_group/presentation/dialogs/edit_idea_dialog.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/idea_card.dart';
import 'package:booking_group_flutter/models/idea.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupIdeasPage extends StatefulWidget {
  final int groupId;
  final UserProfile? leader;

  const GroupIdeasPage({
    super.key,
    required this.groupId,
    required this.leader,
  });

  @override
  State<GroupIdeasPage> createState() => _GroupIdeasPageState();
}

class _GroupIdeasPageState extends State<GroupIdeasPage> {
  final MyGroupApi _myGroupApi = MyGroupApi();

  List<Idea> _ideas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ideas = await _myGroupApi.getGroupIdeas(widget.groupId);
      setState(() {
        _ideas = ideas;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isUserLeader() {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    return widget.leader?.email == currentUserEmail;
  }

  Future<void> _showCreateIdeaDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CreateIdeaDialog(),
    );

    if (result != null && mounted) {
      try {
        final success = await _myGroupApi.createIdea(
          title: result['title']!,
          description: result['description']!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo ý tưởng thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadIdeas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showEditIdeaDialog(Idea idea) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditIdeaDialog(idea: idea),
    );

    if (result != null && mounted) {
      try {
        final success = await _myGroupApi.updateIdea(
          ideaId: idea.id,
          title: result['title']!,
          description: result['description']!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật ý tưởng thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadIdeas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteIdea(Idea idea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ý tưởng "${idea.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await _myGroupApi.deleteIdea(idea.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa ý tưởng thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadIdeas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = _isUserLeader();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ý tưởng của nhóm'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadIdeas,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _ideas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có ý tưởng nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  if (isLeader) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateIdeaDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo ý tưởng đầu tiên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadIdeas,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _ideas.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return IdeaCard(
                    idea: _ideas[index],
                    isLeader: isLeader,
                    onEdit: () => _showEditIdeaDialog(_ideas[index]),
                    onDelete: () => _deleteIdea(_ideas[index]),
                  );
                },
              ),
            ),
      floatingActionButton: isLeader && _ideas.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showCreateIdeaDialog,
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
