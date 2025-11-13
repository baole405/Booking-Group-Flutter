import 'package:booking_group_flutter/features/chat/presentation/widgets/chat_view.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MyGroupApi _myGroupApi = MyGroupApi();

  MyGroup? _myGroup;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final group = await _myGroupApi.getMyGroup();
      if (!mounted) return;
      setState(() {
        _myGroup = group;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _myGroup;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadGroup,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới nhóm',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(group),
    );
  }

  Widget _buildBody(MyGroup? group) {
    if (_errorMessage != null) {
      return _JoinGroupNotice(onRetry: _loadGroup);
    }

    if (group == null) {
      return const _JoinGroupNotice();
    }

    return ChatView(groupId: group.id);
  }
}

class _JoinGroupNotice extends StatelessWidget {
  const _JoinGroupNotice({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: Color(0xFF8B5CF6)),
            const SizedBox(height: 16),
            const Text(
              'Bạn cần tham gia một nhóm trước khi có thể sử dụng chat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
