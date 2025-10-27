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
import 'package:booking_group_flutter/resources/join_request_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final JoinRequestApi _joinRequestApi = JoinRequestApi();

  // State variables
  bool _isLoading = true;
  String? _error;
  String? _userEmail;
  int _requestCount = 0;

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

      // Load join requests count
      await _loadRequestCount();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      print('❌ Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load join requests count
  Future<void> _loadRequestCount() async {
    try {
      final requests = await _joinRequestApi.getMyJoinRequests();
      setState(() {
        // Count only pending requests
        _requestCount = requests
            .where((r) => r.status.toUpperCase() == 'PENDING')
            .length;
      });
    } catch (e) {
      print('❌ Error loading requests: $e');
      setState(() {
        _requestCount = 0;
      });
    }
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const YourRequestsPage(),
                              ),
                            );
                            // Reload count after returning
                            _loadRequestCount();
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
