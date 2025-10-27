import 'package:booking_group_flutter/features/groups/presentation/pages/groups_list_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/group_ideas_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/group_info_card.dart';
import 'package:booking_group_flutter/features/my_group/presentation/widgets/members_section.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
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

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData({int retryCount = 0}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final myGroup = await _myGroupApi.getMyGroup();

      if (myGroup != null) {
        final results = await Future.wait([
          _myGroupApi.getGroupMembers(myGroup.id),
          _myGroupApi.getGroupLeader(myGroup.id),
        ]);

        setState(() {
          _myGroup = myGroup;
          _members = results[0] as List<GroupMember>;
          _leader = results[1] as UserProfile?;
        });
      }
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
                    ),
                    const SizedBox(height: 24),
                    MembersSection(members: _members, leader: _leader),
                    const SizedBox(height: 24),
                    _buildIdeasCard(),
                  ],
                ),
              ),
            ),
    );
  }
}
