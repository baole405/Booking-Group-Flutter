import 'package:booking_group_flutter/core/services/api_service.dart';
import 'package:booking_group_flutter/features/forum/presentation/pages/forum_page.dart';
import 'package:booking_group_flutter/features/groups/presentation/pages/groups_list_page.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/error_state_widget.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/groups_your_group_section.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/home_header.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/information_access_section.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/loading_widget.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/your_request_section_card.dart';
import 'package:booking_group_flutter/features/ideas/presentation/pages/all_ideas_page.dart';
import 'package:booking_group_flutter/features/my_group/presentation/pages/my_group_detail_page.dart';
import 'package:booking_group_flutter/features/requests/presentation/pages/your_requests_page.dart';
import 'package:booking_group_flutter/models/join_request.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/resources/join_request_api.dart';
import 'package:booking_group_flutter/resources/my_group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final JoinRequestApi _joinRequestApi = JoinRequestApi();
  final MyGroupApi _myGroupApi = MyGroupApi();

  // State variables
  bool _isLoading = true;
  String? _error;
  String? _userEmail;
  int _requestCount = 0;
  MyGroup? _myGroup;
  JoinRequest? _latestPendingRequest;
  String? _latestRequestStatusLabel;
  String? _latestRequestTimeLabel;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user info
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userEmail = user.email;
      }

      // Load group & join requests information
      await _loadGroupAndRequests();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      print('❌ Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

  }

  /// Load the current group info and pending join requests for the home highlights
  Future<void> _loadGroupAndRequests() async {
    MyGroup? myGroup;
    List<JoinRequest> requests = [];

    try {
      myGroup = await _myGroupApi.getMyGroup();
    } catch (e) {
      print('❌ Error loading my group: $e');
    }

    try {
      requests = await _joinRequestApi.getMyJoinRequests();
    } catch (e) {
      print('❌ Error loading requests: $e');
    }

    if (!mounted) return;

    final pendingRequests = _extractPendingRequests(requests);
    final latestRequest = pendingRequests.isNotEmpty ? pendingRequests.first : null;

    setState(() {
      _myGroup = myGroup;
      _requestCount = pendingRequests.length;
      _latestPendingRequest = latestRequest;
      _latestRequestStatusLabel = _buildLatestStatusLabel(latestRequest);
      _latestRequestTimeLabel =
          latestRequest != null ? _formatRequestTime(latestRequest.createdAt) : null;
    });
  }

  /// Refresh join requests data only (used after returning from the request screen)
  Future<void> _refreshJoinRequests() async {
    try {
      final requests = await _joinRequestApi.getMyJoinRequests();
      if (!mounted) return;

      final pendingRequests = _extractPendingRequests(requests);
      final latestRequest = pendingRequests.isNotEmpty ? pendingRequests.first : null;

      setState(() {
        _requestCount = pendingRequests.length;
        _latestPendingRequest = latestRequest;
        _latestRequestStatusLabel = _buildLatestStatusLabel(latestRequest);
        _latestRequestTimeLabel =
            latestRequest != null ? _formatRequestTime(latestRequest.createdAt) : null;
      });
    } catch (e) {
      print('❌ Error refreshing requests: $e');
      if (!mounted) return;
      setState(() {
        _requestCount = 0;
        _latestPendingRequest = null;
        _latestRequestStatusLabel = null;
        _latestRequestTimeLabel = null;
      });
    }
  }

  /// Refresh only the current group data (used when returning from other screens)
  Future<void> _refreshMyGroup() async {
    try {
      final myGroup = await _myGroupApi.getMyGroup();
      if (!mounted) return;
      setState(() {
        _myGroup = myGroup;
      });
    } catch (e) {
      print('❌ Error refreshing my group: $e');
    }
  }

  List<JoinRequest> _extractPendingRequests(List<JoinRequest> requests) {
    final pending = requests
        .where((r) => r.status.toUpperCase() == 'PENDING')
        .toList()
      ..sort((a, b) => _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)));
    return pending;
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  String? _formatRequestTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return 'Gửi lúc ${DateFormat('HH:mm dd/MM').format(date)}';
    } catch (_) {
      return null;
    }
  }

  String? _buildLatestStatusLabel(JoinRequest? request) {
    if (request == null) return null;

    final status = request.status.toUpperCase();
    if (status == 'PENDING') {
      final int groupNumber = request.group?.id ?? request.groupId;
      if (groupNumber > 0) {
        return 'Đang chờ Leader nhóm số $groupNumber xử lý';
      }
      return 'Đang chờ Leader xử lý';
    }

    switch (status) {
      case 'APPROVED':
        return 'Đã được chấp nhận';
      case 'REJECTED':
        return 'Đã bị từ chối';
      default:
        return request.status;
    }
  }

  String? _deriveGroupTitle(JoinRequest? request) {
    if (request == null) return null;

    final String? groupTitle = request.group?.title;
    if (groupTitle != null && groupTitle.trim().isNotEmpty) {
      return groupTitle;
    }

    if (request.groupId > 0) {
      return 'Nhóm #${request.groupId}';
    }

    return null;
  }

  /// Logout handler
  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Logout from all services
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await _apiService.logout();

      if (mounted) {
        // Navigate to login page
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  // Refresh data
  Future<void> _handleRefresh() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: HomeHeader(
                  userEmail: _userEmail,
                  onLogout: _handleLogout,
                ),
              ),

              // Main Content
              if (_isLoading)
                const SliverFillRemaining(child: LoadingWidget())
              else if (_error != null)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    error: _error!,
                    onRetry: _handleRefresh,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Section 1: Groups and Your Group
                      GroupsYourGroupSection(
                        onGroupsTap: () {
                          // Navigate to Groups List page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupsListPage(),
                            ),
                          );
                        },
                        onYourGroupTap: () {
                          // Navigate to My Group Detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyGroupDetailPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Section 1.5: Your Request Card (below Groups section)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: YourRequestSectionCard(
                          requestCount: _requestCount,
                          latestGroupTitle: _myGroup == null
                              ? _deriveGroupTitle(_latestPendingRequest)
                              : null,
                          latestStatusLabel:
                              _myGroup == null ? _latestRequestStatusLabel : null,
                          latestTimeLabel:
                              _myGroup == null ? _latestRequestTimeLabel : null,
                          showLatestRequestHighlight:
                              _myGroup == null && _latestPendingRequest != null,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const YourRequestsPage(),
                              ),
                            );
                            await Future.wait([
                              _refreshJoinRequests(),
                              _refreshMyGroup(),
                            ]);
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Section 2: Information Access
                      InformationAccessSection(
                        onForumTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForumPage(),
                            ),
                          );
                        },
                        onIdeaTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllIdeasPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
