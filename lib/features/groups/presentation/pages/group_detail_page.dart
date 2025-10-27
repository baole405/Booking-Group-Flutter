import 'package:booking_group_flutter/features/groups/presentation/widgets/group_detail_info_card.dart';
import 'package:booking_group_flutter/features/groups/presentation/widgets/group_detail_leader_section.dart';
import 'package:booking_group_flutter/features/groups/presentation/widgets/group_detail_members_section.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/my_group_detail_page.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/resources/groups_api.dart';
import 'package:booking_group_flutter/resources/join_request_api.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;
  final String groupTitle;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.groupTitle,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final GroupsApi _groupsApi = GroupsApi();
  final JoinRequestApi _joinRequestApi = JoinRequestApi();
  final MyGroupApi _myGroupApi = MyGroupApi();

  Map<String, dynamic>? _groupDetail;
  List<GroupMember> _members = [];
  Map<String, dynamic>? _leader;
  int _memberCount = 0;
  bool _isLoading = true;
  String? _error;
  bool _isUserInGroup = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadGroupDetail();
  }

  Future<void> _loadGroupDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _groupsApi.getGroupById(widget.groupId),
        _groupsApi.getGroupMembers(widget.groupId),
        _groupsApi.getGroupLeader(widget.groupId),
        _groupsApi.getGroupMemberCount(widget.groupId),
      ]);

      setState(() {
        _groupDetail = results[0] as Map<String, dynamic>?;
        _members = results[1] as List<GroupMember>;
        _leader = results[2] as Map<String, dynamic>?;
        _memberCount = results[3] as int;

        // Debug log to check data types
        print('🔍 Group Detail Data:');
        print(
          '  - title: ${_groupDetail?['title']} (${_groupDetail?['title'].runtimeType})',
        );
        print(
          '  - status: ${_groupDetail?['status']} (${_groupDetail?['status'].runtimeType})',
        );
        print(
          '  - type: ${_groupDetail?['type']} (${_groupDetail?['type'].runtimeType})',
        );
        print(
          '  - description: ${_groupDetail?['description']} (${_groupDetail?['description'].runtimeType})',
        );
      });

      // Check if user is in this group
      await _checkUserInGroup();
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

  Future<void> _checkUserInGroup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final myGroup = await _myGroupApi.getMyGroup();
      setState(() {
        _isUserInGroup = myGroup != null && myGroup.id == widget.groupId;
      });
    } catch (e) {
      print('Error checking user in group: $e');
      setState(() {
        _isUserInGroup = false;
      });
    }
  }

  Future<void> _handleJoinGroup() async {
    final isFormingGroup = _groupDetail?['status']?.toUpperCase() == 'FORMING';

    if (isFormingGroup) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận làm trưởng nhóm'),
          content: const Text(
            'Bạn sẽ trở thành trưởng nhóm khi tham gia nhóm này.\n\nBạn có chắc chắn muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final success = await _joinRequestApi.joinGroup(widget.groupId);
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFormingGroup
                  ? 'Chúc mừng! Bạn đã trở thành trưởng nhóm'
                  : 'Đã gửi yêu cầu tham gia nhóm thành công',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // If FORMING group, user became leader -> redirect to My Group
        if (isFormingGroup) {
          // Wait for backend to update the relationship
          print('⏳ Waiting for backend to complete group setup...');

          // Retry checking my-group until it succeeds or times out
          bool groupReady = false;
          int retries = 0;
          const maxRetries = 5;

          while (!groupReady && retries < maxRetries) {
            await Future.delayed(Duration(seconds: retries == 0 ? 2 : 3));

            try {
              final myGroup = await _myGroupApi.getMyGroup();
              if (myGroup != null && myGroup.id == widget.groupId) {
                groupReady = true;
                print('✅ Group relationship established!');
              } else {
                retries++;
                print(
                  '⏳ Retry ${retries}/${maxRetries} - Group not ready yet...',
                );
              }
            } catch (e) {
              retries++;
              print('⏳ Retry ${retries}/${maxRetries} - Error: $e');
            }
          }

          if (mounted) {
            if (groupReady) {
              // Navigate to My Group Detail
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MyGroupDetailPage(),
                ),
                (route) => route.isFirst, // Keep only the home route
              );
            } else {
              // If still not ready after retries, show message and go back to home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đã tham gia nhóm thành công! Vui lòng kiểm tra lại trong "Your Group"',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        } else {
          // For ACTIVE groups, just reload the page
          await _loadGroupDetail();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showJoinButton =
        !_isUserInGroup &&
        _groupDetail != null &&
        _groupDetail!['status']?.toUpperCase() == 'ACTIVE';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupTitle),
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
                    onPressed: _loadGroupDetail,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGroupDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_groupDetail != null)
                      GroupDetailInfoCard(
                        groupDetail: _groupDetail!,
                        memberCount: _memberCount,
                      ),
                    const SizedBox(height: 16),
                    if (_groupDetail != null)
                      GroupDetailLeaderSection(
                        leader: _leader,
                        groupStatus: _groupDetail!['status'] ?? '',
                        isUserInGroup: _isUserInGroup,
                        onJoinAsLeader: _isJoining ? null : _handleJoinGroup,
                      ),
                    const SizedBox(height: 16),
                    GroupDetailMembersSection(
                      members: _members,
                      memberCount: _memberCount,
                      leader: _leader,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: showJoinButton
          ? FloatingActionButton.extended(
              onPressed: _isJoining ? null : _handleJoinGroup,
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              icon: _isJoining
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.group_add),
              label: Text(_isJoining ? 'Đang gửi...' : 'Tham gia nhóm'),
            )
          : null,
    );
  }
}
