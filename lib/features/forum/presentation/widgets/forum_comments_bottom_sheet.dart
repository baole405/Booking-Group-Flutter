import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comment_input.dart';
import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comment_profile_sheet.dart';
import 'package:booking_group_flutter/features/forum/presentation/widgets/forum_comment_tile.dart';
import 'package:booking_group_flutter/models/comment.dart';
import 'package:booking_group_flutter/models/post.dart';
import 'package:booking_group_flutter/resources/comments_api.dart';
import 'package:booking_group_flutter/resources/groups_api.dart';
import 'package:booking_group_flutter/resources/invite_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForumCommentsBottomSheet extends StatefulWidget {
  final Post post;
  final BuildContext parentContext;

  const ForumCommentsBottomSheet({
    super.key,
    required this.post,
    required this.parentContext,
  });

  @override
  State<ForumCommentsBottomSheet> createState() =>
      _ForumCommentsBottomSheetState();
}

class _ForumCommentsBottomSheetState extends State<ForumCommentsBottomSheet> {
  final CommentsApi _commentsApi = CommentsApi();
  final InviteApi _inviteApi = InviteApi();
  final GroupsApi _groupsApi = GroupsApi();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSendingComment = false;
  bool _canInvite = false;
  String? _error;
  int? _groupId;
  Set<int> _groupMemberIds = {};
  Set<int> _invitedUserIds = {};
  Map<int, bool> _inviteLoading = {};
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadComments(),
        _evaluateInvitePermission(),
      ]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadComments() async {
    final comments = await _commentsApi.getCommentsByPost(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  Future<void> _evaluateInvitePermission() async {
    final group = widget.post.groupResponse;
    final currentEmail = _currentUserEmail;

    if (group == null || currentEmail == null) {
      _canInvite = false;
      return;
    }

    try {
      final leader = await _groupsApi.getGroupLeader(group.id);
      final leaderEmail = leader != null ? leader['email'] as String? : null;
      final isLeader = leaderEmail != null && leaderEmail == currentEmail;
      final isPostOwner = widget.post.userResponse.email == currentEmail;

      if (isLeader || isPostOwner) {
        final members = await _groupsApi.getGroupMembers(group.id);
        _groupMemberIds = members.map((member) => member.id).toSet();
        _groupId = group.id;
        _canInvite = true;
      } else {
        _canInvite = false;
      }
    } catch (e) {
      debugPrint('Error evaluating invite permission: $e');
      _canInvite = false;
    }
  }

  bool _isMember(Comment comment) {
    return _groupMemberIds.contains(comment.userResponse.id);
  }

  bool _isInvited(Comment comment) {
    return _invitedUserIds.contains(comment.userResponse.id);
  }

  bool _isSelf(Comment comment) {
    return comment.userResponse.email == _currentUserEmail;
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      await _commentsApi.createComment(
        postId: widget.post.id,
        content: content,
      );

      _commentController.clear();
      await _loadComments();
      _commentFocusNode.requestFocus();
    } catch (e) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  Future<void> _handleInvite(Comment comment, BuildContext sheetContext) async {
    if (!_canInvite || _groupId == null) {
      return;
    }

    final inviteeId = comment.userResponse.id;
    if (inviteeId == 0 || _isMember(comment) || _isInvited(comment)) {
      return;
    }

    setState(() {
      _inviteLoading[inviteeId] = true;
    });

    try {
      await _inviteApi.createInvite(
        groupId: _groupId!,
        inviteeId: inviteeId,
      );

      if (mounted) {
        setState(() {
          _invitedUserIds.add(inviteeId);
        });
      }

      if (Navigator.of(sheetContext).canPop()) {
        Navigator.of(sheetContext).pop();
      }

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lời mời tham gia nhóm'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _inviteLoading.remove(inviteeId);
        });
      }
    }
  }

  Future<void> _openProfile(Comment comment) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ForumCommentProfileSheet(
          comment: comment,
          canInvite: _canInvite &&
              !_isMember(comment) &&
              !_isInvited(comment) &&
              !_isSelf(comment) &&
              widget.post.groupResponse != null,
          isInviting: _inviteLoading[comment.userResponse.id] ?? false,
          isMember: _isMember(comment),
          alreadyInvited: _isInvited(comment),
          isSelf: _isSelf(comment),
          onInvite: _canInvite && widget.post.groupResponse != null
              ? () => _handleInvite(comment, sheetContext)
              : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Bình luận bài viết',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_canInvite && widget.post.groupResponse != null)
                    const Icon(Icons.verified, color: Color(0xFF8B5CF6)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.redAccent),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('Chưa có bình luận nào.'),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return ForumCommentTile(
                                  comment: comment,
                                  onProfileTap: () => _openProfile(comment),
                                  canInvite: _canInvite &&
                                      !_isSelf(comment) &&
                                      widget.post.groupResponse != null,
                                  isMember: _isMember(comment),
                                  alreadyInvited: _isInvited(comment),
                                );
                              },
                            ),
            ),
            const Divider(height: 1),
            ForumCommentInput(
              controller: _commentController,
              focusNode: _commentFocusNode,
              isSending: _isSendingComment,
              onSend: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}
