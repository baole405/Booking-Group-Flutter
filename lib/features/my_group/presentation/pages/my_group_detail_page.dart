import 'package:booking_group_flutter/features/groups/presentation/pages/groups_list_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/group_ideas_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_info_card.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_member_profile_sheet.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/members_section.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:booking_group_flutter/resources/notifications_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyGroupDetailPage extends StatefulWidget {
  const MyGroupDetailPage({super.key});

  @override
  State<MyGroupDetailPage> createState() => _MyGroupDetailPageState();
}

class _MyGroupDetailPageState extends State<MyGroupDetailPage> {
  final MyGroupApi _myGroupApi = MyGroupApi();
  final NotificationsApi _notificationsApi = NotificationsApi();

  MyGroup? _myGroup;
  List<GroupMember> _members = const [];
  UserProfile? _leader;

  bool _isLoading = true;
  bool _isBusy = false;
  bool _isLeader = false;
  String? _errorMessage;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    _loadGroupOverview();
  }

  Future<void> _loadGroupOverview({int retry = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final myGroup = await _myGroupApi.getMyGroup();
      if (myGroup == null) {
        setState(() {
          _myGroup = null;
          _members = const [];
          _leader = null;
          _isLeader = false;
        });
        return;
      }

      final results = await Future.wait([
        _myGroupApi.getGroupMembers(myGroup.id),
        _myGroupApi.getGroupLeader(myGroup.id),
      ]);

      final leaderProfile = results[1] as UserProfile?;
      final leaderEmail = leaderProfile?.email.toLowerCase();

      setState(() {
        _myGroup = myGroup;
        _members = results[0] as List<GroupMember>;
        _leader = leaderProfile;
        _isLeader = leaderEmail != null && leaderEmail == _currentUserEmail;
      });
    } catch (error) {
      if (error.toString().contains('500') && retry < 2) {
        await Future.delayed(const Duration(seconds: 2));
        return _loadGroupOverview(retry: retry + 1);
      }

      setState(() {
        _errorMessage = error.toString();
        _isLeader = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Your Group'),
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      actions: [
        if (!_isLoading && _myGroup != null)
          TextButton.icon(
            onPressed: _isBusy ? null : () async => _handleLeaveGroup(),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Leave', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myGroup == null) {
      return _buildEmptyState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadGroupOverview(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _buildLoadedContent(),
      ),
    );
  }

  Widget _buildLoadedContent() {
    final group = _myGroup!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupInfoCard(
          group: group,
          memberCount: _members.length,
          showLeaderActions: _isLeader,
          actionsEnabled: !_isBusy,
          onEditInfo: _isLeader ? _handleEditGroupInfo : null,
          onToggleType: _isLeader ? _handleToggleGroupType : null,
        ),
        const SizedBox(height: 24),
        MembersSection(
          members: _members,
          leader: _leader,
          currentUserEmail: _currentUserEmail,
          onMemberTap: _handleMemberTap,
          interactionsDisabled: _isBusy,
        ),
        const SizedBox(height: 24),
        _buildIdeasCard(),
        if (_isLeader) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isBusy ? null : _handleCompleteGroup,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark group as completed'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
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
              'You are not part of any group yet.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Join a group to start collaborating with other members.',
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
              label: const Text('Browse groups'),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGroupOverview,
              child: const Text('Try again'),
            ),
          ],
        ),
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
                      'Group ideas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View and manage submitted ideas.',
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

  Future<void> _handleEditGroupInfo() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final updatedValues = await _showEditGroupDialog(group);
    if (updatedValues == null) return;

    await _performGroupAction(
      () => _myGroupApi.updateGroupInfo(
        groupId: group.id,
        title: updatedValues['title']!,
        description: updatedValues['description']!,
      ),
      successMessage: 'Group info updated',
    );
  }

  Future<void> _handleToggleGroupType() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final currentType = group.type.toUpperCase();
    final nextType = currentType == 'PUBLIC' ? 'PRIVATE' : 'PUBLIC';

    final confirmed = await _showConfirmationDialog(
      title: 'Change group type',
      message:
          'Switch group visibility to ${nextType == 'PUBLIC' ? 'public' : 'private'}?',
      confirmLabel: 'Confirm',
    );

    if (confirmed != true) return;

    await _performGroupAction(
      () => _myGroupApi.changeGroupType(),
      successMessage:
          'Group is now ${nextType == 'PUBLIC' ? 'public' : 'private'}',
    );
  }

  Future<void> _handleCompleteGroup() async {
    final group = _myGroup;
    if (group == null || !_isLeader) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Complete group',
      message:
          'After marking as completed you will not be able to change members. Continue?',
      confirmLabel: 'Complete',
    );

    if (confirmed != true) return;

    await _performGroupAction(
      () => _myGroupApi.completeGroup(),
      successMessage: 'Group marked as completed',
    );
  }

  Future<void> _handleMemberTap(GroupMember member) async {
    final isCurrentUser =
        _currentUserEmail != null &&
        member.email.toLowerCase() == _currentUserEmail;

    bool isSheetBusy = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> kickMember() async {
              if (_isBusy || isSheetBusy) return;
              setModalState(() {
                isSheetBusy = true;
              });
              await _confirmAndRemoveMember(member, sheetContext);
              if (context.mounted) {
                setModalState(() {
                  isSheetBusy = false;
                });
              }
            }

            return GroupMemberProfileSheet(
              member: member,
              isCurrentUser: isCurrentUser,
              viewerIsLeader: _isLeader,
              isProcessing: isSheetBusy || _isBusy,
              onKickMember: (!_isLeader || isCurrentUser) ? null : kickMember,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmAndRemoveMember(
    GroupMember member,
    BuildContext sheetContext,
  ) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Remove member',
      message: 'Remove ${member.fullName} from the group?',
      confirmLabel: 'Remove',
    );

    if (confirmed != true) return;

    var removalCompleted = false;

    await _performGroupAction(() async {
      await _myGroupApi.removeMember(member.id);
      removalCompleted = true;

      final groupName = _myGroup?.title ?? 'your group';
      try {
        await _notificationsApi.sendMemberRemovedNotification(
          userId: member.id,
          groupName: groupName,
        );
      } catch (error) {
        debugPrint('Failed to send removal notification: $error');
      }
    }, successMessage: 'Removed ${member.fullName} from the group');

    if (!mounted) return;
    if (removalCompleted && sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _handleLeaveGroup() async {
    final group = _myGroup;
    if (group == null || _isBusy) return;

    if (_isLeader) {
      final hasOtherActiveMembers = _members.any(
        (member) =>
            member.isActive && member.email.toLowerCase() != _currentUserEmail,
      );

      if (hasOtherActiveMembers) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Leader cannot leave while there are other active members.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final confirmed = await _showConfirmationDialog(
      title: 'Leave group',
      message: 'Leave ${group.title}?',
      confirmLabel: 'Leave',
    );

    if (confirmed != true) return;

    await _performGroupAction(() async {
      await _myGroupApi.leaveGroup();
    }, successMessage: 'You have left the group');
  }

  Future<void> _performGroupAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() {
      _isBusy = true;
    });

    try {
      await action();
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      await _loadGroupOverview();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<Map<String, String>?> _showEditGroupDialog(MyGroup group) async {
    final titleController = TextEditingController(text: group.title);
    final descriptionController = TextEditingController(
      text: group.description,
    );
    String? localError;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update group info'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Group name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 4,
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        localError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty) {
                      setDialogState(() {
                        localError = 'Group name cannot be empty';
                      });
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop({'title': title, 'description': description});
                  },
                  child: const Text('Save'),
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
              child: const Text('Cancel'),
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

  void _navigateToIdeasPage() {
    final group = _myGroup;
    if (group == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupIdeasPage(groupId: group.id, leader: _leader),
      ),
    );
  }
}
