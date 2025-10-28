import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comments_bottom_sheet.dart';
import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_post_card.dart';
import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comment_profile_sheet.dart';
import 'package:booking_group_flutter/features/groups/presentation/pages/group_detail_page.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/post.dart';
import 'package:booking_group_flutter/resources/forum_api.dart';
import 'package:booking_group_flutter/resources/invite_api.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumApi _forumApi = ForumApi();
  final MyGroupApi _myGroupApi = MyGroupApi();
  final InviteApi _inviteApi = InviteApi();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  MyGroup? _myGroup;
  bool _isLeader = false;
  Set<int> _myGroupMemberIds = {};
  final Map<int, bool> _inviteLoading = {};
  final Set<int> _invitedUserIds = {};
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _forumApi.getAllPosts(),
        _loadLeadership(),
      ]);

      setState(() {
        _posts = results.first as List<Post>;
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

  Future<void> _loadLeadership() async {
    final currentEmail = _currentUserEmail;

    if (currentEmail == null) {
      if (!mounted) return;
      setState(() {
        _myGroup = null;
        _isLeader = false;
        _myGroupMemberIds = {};
      });
      return;
    }

    try {
      final myGroup = await _myGroupApi.getMyGroup();
      if (!mounted) return;

      if (myGroup == null) {
        setState(() {
          _myGroup = null;
          _isLeader = false;
          _myGroupMemberIds = {};
        });
        return;
      }

      final leader = await _myGroupApi.getGroupLeader(myGroup.id);
      final isLeader = leader != null && leader.email == currentEmail;

      Set<int> memberIds = {};
      if (isLeader) {
        final members = await _myGroupApi.getGroupMembers(myGroup.id);
        memberIds = members.map((member) => member.id).toSet();
      }

      if (!mounted) return;

      setState(() {
        _myGroup = myGroup;
        _isLeader = isLeader;
        _myGroupMemberIds = memberIds;
      });
    } catch (e) {
      debugPrint('Error loading leadership data: $e');
      if (!mounted) return;
      setState(() {
        _myGroup = null;
        _isLeader = false;
        _myGroupMemberIds = {};
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
                    onPressed: _loadData,
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
              onRefresh: _loadData,
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
                    onPosterTap: post.type.toUpperCase() == 'FIND_GROUP'
                        ? () => _openPosterProfile(post)
                        : null,
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

  void _openPosterProfile(Post post) {
    final user = post.userResponse;
    final inviteeId = user.id;
    final isSelf = _currentUserEmail != null &&
        _currentUserEmail!.toLowerCase() == user.email.toLowerCase();
    final isMember = _myGroupMemberIds.contains(inviteeId);
    final alreadyInvited = _invitedUserIds.contains(inviteeId);
    final group = _myGroup;
    final canInvite = _isLeader && group != null && !isSelf;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ForumCommentProfileSheet(
        user: user,
        note: post.content,
        noteLabel: 'Nội dung bài đăng',
        canInvite: canInvite && !isMember && !alreadyInvited,
        isInviting: _inviteLoading[inviteeId] ?? false,
        isMember: isMember,
        alreadyInvited: alreadyInvited,
        isSelf: isSelf,
        onInvite: canInvite && !isMember && !alreadyInvited
            ? () => _inviteFromPost(
                  inviteeId: inviteeId,
                  groupId: group!.id,
                  sheetContext: sheetContext,
                  displayName: user.fullName.isNotEmpty
                      ? user.fullName
                      : user.email,
                )
            : null,
      ),
    );
  }

  Future<void> _inviteFromPost({
    required int inviteeId,
    required int groupId,
    required BuildContext sheetContext,
    required String displayName,
  }) async {
    setState(() {
      _inviteLoading[inviteeId] = true;
    });

    try {
      await _inviteApi.createInvite(groupId: groupId, inviteeId: inviteeId);
      if (!mounted) return;

      setState(() {
        _invitedUserIds.add(inviteeId);
      });

      Navigator.of(sheetContext).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi lời mời đến $displayName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _inviteLoading.remove(inviteeId);
      });
    }
  }
}
