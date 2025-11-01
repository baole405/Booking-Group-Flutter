import 'dart:async';

import 'package:booking_group_flutter/features/groups/presentation/pages/groups_list_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/group_ideas_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_info_card.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_member_profile_sheet.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/members_section.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:booking_group_flutter/resources/notifications_api.dart';
import 'package:booking_group_flutter/resources/votes_api.dart';
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
  final VotesApi _votesApi = VotesApi();

  MyGroup? _myGroup;
  List<GroupMember> _members = const [];
  UserProfile? _leader;

  bool _isGroupLoading = true;
  bool _isVoteLoading = false;
  bool _isBusy = false;
  bool _isLeader = false;
  String? _errorMessage;
  String? _currentUserEmail;

  Map<String, dynamic>? _activeVote;
  List<Map<String, dynamic>> _activeVoteChoices = const [];
  bool _hasVoted = false;

  Timer? _votePollingTimer;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    _loadGroupOverview();
  }

  @override
  void dispose() {
    _votePollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGroupOverview({bool fetchVotes = true}) async {
    setState(() {
      _isGroupLoading = true;
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
        _stopVotePolling();
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

      if (fetchVotes) {
        await _loadVotes();
        _startVotePolling();
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLeader = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGroupLoading = false;
        });
      }
    }
  }

  void _startVotePolling() {
    _votePollingTimer?.cancel();
    _votePollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _loadVotes(updateOnly: true);
    });
  }

  void _stopVotePolling() {
    _votePollingTimer?.cancel();
    _votePollingTimer = null;
  }

  Future<void> _loadVotes({bool updateOnly = false}) async {
    final group = _myGroup;
    if (group == null) {
      _stopVotePolling();
      return;
    }

    if (!mounted) return;

    if (!updateOnly) {
      setState(() {
        _isVoteLoading = true;
      });
    }

    try {
      final voteList = await _votesApi.getGroupVotes(group.id);
      final openVotes = voteList
          .where((vote) => (vote['status'] as String?)?.toUpperCase() == 'OPEN')
          .toList();

      Map<String, dynamic>? selectedVote;
      if (_activeVote != null &&
          openVotes.any((vote) => vote['id'] == _activeVote!['id'])) {
        selectedVote = openVotes.firstWhere(
          (vote) => vote['id'] == _activeVote!['id'],
        );
      } else {
        selectedVote = openVotes.isNotEmpty ? openVotes.first : null;
      }

      List<Map<String, dynamic>> choices = const [];
      bool hasVoted = false;

      if (selectedVote != null) {
        choices = await _votesApi.getVoteChoices(selectedVote['id'] as int);
        final currentEmail = _currentUserEmail;
        if (currentEmail != null) {
          hasVoted = choices.any((choice) {
            final voterEmail =
                (choice['userEmail'] ?? choice['email']) as String?;
            return voterEmail?.toLowerCase() == currentEmail;
          });
        }
      }

      if (!mounted) return;

      setState(() {
        _activeVote = selectedVote;
        _activeVoteChoices = choices;
        _hasVoted = hasVoted;
      });
    } catch (error) {
      if (mounted && !updateOnly) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load votes: $error')));
      }
      if (mounted) {
        setState(() {
          _activeVote = null;
          _activeVoteChoices = const [];
          _hasVoted = false;
        });
      }
    } finally {
      if (!updateOnly && mounted) {
        setState(() {
          _isVoteLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isGroupLoading ? _buildLoading() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Your Group'),
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      actions: [
        if (!_isGroupLoading && _myGroup != null)
          TextButton.icon(
            onPressed: _isBusy ? null : _handleLeaveGroup,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildBody() {
    if (_myGroup == null) {
      return _buildEmptyState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadGroupOverview(fetchVotes: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGroupHeader(),
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
          const SizedBox(height: 24),
          _buildVotePanel(),
          if (_isLeader) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isBusy ? null : _handleCompleteGroup,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark group as completed'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupHeader() {
    final group = _myGroup!;
    return GroupInfoCard(
      group: group,
      memberCount: _members.length,
      showLeaderActions: _isLeader,
      actionsEnabled: !_isBusy,
      onEditInfo: _isLeader ? _handleEditGroupInfo : null,
      onToggleType: _isLeader ? _handleToggleGroupType : null,
    );
  }

  Widget _buildVotePanel() {
    if (_isVoteLoading) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_activeVote == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No active votes at the moment.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final vote = _activeVote!;
    final targetName =
        vote['targetUserFullName'] ??
        vote['targetUserName'] ??
        vote['targetUserEmail'] ??
        'Member';
    final targetEmail = vote['targetUserEmail'] ?? 'Unknown email';
    final targetMajor = vote['targetUserMajor'] ?? 'Major not available';
    final closedAt = vote['closedAt'];
    final status = (vote['status'] as String?)?.toUpperCase();

    final yesVotes = _activeVoteChoices
        .where(
          (choice) =>
              (choice['choiceValue'] as String?)?.toUpperCase() == 'YES',
        )
        .length;
    final noVotes = _activeVoteChoices
        .where(
          (choice) => (choice['choiceValue'] as String?)?.toUpperCase() == 'NO',
        )
        .length;

    final bool voteClosed = status == 'CLOSED';
    final bool buttonsDisabled = voteClosed || _isBusy || _hasVoted;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join request vote',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    targetName.isNotEmpty ? targetName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        targetMajor,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        targetEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (closedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Closes at: $closedAt',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton('YES', yesVotes, buttonsDisabled),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoteButton('NO', noVotes, buttonsDisabled),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVoteStatus(voteClosed: voteClosed),
            if (_isLeader && !voteClosed) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _isBusy
                      ? null
                      : () => _finalizeVote(vote['id'] as int),
                  icon: const Icon(Icons.gavel_outlined),
                  label: const Text('Finalize vote (leader)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoteStatus({required bool voteClosed}) {
    if (_hasVoted) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 6),
          Text(
            'You have already voted',
            style: TextStyle(color: Colors.green.shade700),
          ),
        ],
      );
    }

    if (voteClosed) {
      return Row(
        children: const [
          Icon(Icons.lock, color: Colors.redAccent, size: 18),
          SizedBox(width: 6),
          Text(
            'This vote is closed',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildVoteButton(String choiceValue, int count, bool disabled) {
    return ElevatedButton(
      onPressed: disabled ? null : () => _submitVote(choiceValue),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: choiceValue == 'YES'
            ? const Color(0xFF2563EB)
            : const Color(0xFFDC2626),
        foregroundColor: Colors.white,
      ),
      child: Column(
        children: [
          Text(choiceValue),
          const SizedBox(height: 4),
          Text('$count vote${count == 1 ? '' : 's'}'),
        ],
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
              onPressed: () => _loadGroupOverview(fetchVotes: true),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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

  Future<void> _submitVote(String choice) async {
    final vote = _activeVote;
    if (vote == null || _isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await _votesApi.submitChoice(
        voteId: vote['id'] as int,
        choiceValue: choice,
      );
      await _loadVotes();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Voted $choice successfully')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to vote: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _finalizeVote(int voteId) async {
    setState(() {
      _isBusy = true;
    });

    try {
      await _votesApi.finalizeVote(voteId);
      await _loadVotes();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vote finalized')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to finalize vote: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
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
              setModalState(() => isSheetBusy = true);
              await _confirmAndRemoveMember(member, sheetContext);
              if (context.mounted) {
                setModalState(() => isSheetBusy = false);
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

    await _performGroupAction(
      () async {
        await _myGroupApi.leaveGroup();
      },
      successMessage: 'You have left the group',
      refreshAfter: false,
      onSuccess: () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  Future<void> _performGroupAction(
    Future<void> Function() action, {
    required String successMessage,
    bool refreshAfter = true,
    VoidCallback? onSuccess,
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

      if (refreshAfter) {
        await _loadGroupOverview(fetchVotes: true);
      }

      onSuccess?.call();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
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
      successMessage: 'Group information updated',
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
          'After completing the group you will not be able to change members. Continue?',
      confirmLabel: 'Complete',
    );

    if (confirmed != true) return;

    await _performGroupAction(
      () => _myGroupApi.completeGroup(),
      successMessage: 'Group marked as completed',
    );
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
