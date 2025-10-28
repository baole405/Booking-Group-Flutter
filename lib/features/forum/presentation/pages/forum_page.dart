import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comments_bottom_sheet.dart';
import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_post_card.dart';
import 'package:booking_group_flutter/features/groups/presentation/pages/group_detail_page.dart';
import 'package:booking_group_flutter/models/post.dart';
import 'package:booking_group_flutter/resources/forum_api.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumApi _forumApi = ForumApi();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _forumApi.getAllPosts();
      setState(() {
        _posts = posts;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
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
                    onPressed: _loadPosts,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài đăng nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _posts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return ForumPostCard(
                    post: post,
                    onViewGroup: post.groupResponse != null
                        ? () => _openGroupDetail(post)
                        : null,
                    onOpenComments: () => _openComments(post),
                  );
                },
              ),
            ),
    );
  }

  void _openGroupDetail(Post post) {
    final group = post.groupResponse;
    if (group == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailPage(
          groupId: group.id,
          groupTitle: group.title,
        ),
      ),
    );
  }

  void _openComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ForumCommentsBottomSheet(
        post: post,
        parentContext: context,
      ),
    );
  }
}
