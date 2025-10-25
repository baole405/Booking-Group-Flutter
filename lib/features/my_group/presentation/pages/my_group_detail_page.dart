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

  Future<void> _loadGroupData() async {
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
      } else {
        setState(() {
          _error = 'Bạn chưa tham gia nhóm nào';
        });
      }
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
        title: const Text('Nhóm của bạn'),
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
                    onPressed: _loadGroupData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGroupData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_myGroup != null)
                      GroupInfoCard(
                        group: _myGroup!,
                        memberCount: _members.length,
                      ),
                    const SizedBox(height: 24),
                    MembersSection(members: _members, leader: _leader),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupIdeasPage(
                                groupId: _myGroup!.id,
                                leader: _leader,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.1),
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
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
