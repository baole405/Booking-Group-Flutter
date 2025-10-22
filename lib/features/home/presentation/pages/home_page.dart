import 'dart:convert';

import 'package:booking_group_flutter/core/services/api_service.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/error_state_widget.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/group_grid_section.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/home_header.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/home_search_bar.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/loading_widget.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 🏠 Home Page - Clean Architecture
///
/// Features:
/// - Auto load groups on login (no hot restart needed)
/// - Separated into reusable components
/// - Better state management
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  // State variables
  List<Group> _recommendedGroups = [];
  bool _isLoading = true;
  String? _error;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data and groups
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

      // Load groups from Backend
      await _loadGroups();
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

  /// Load groups from Backend API
  Future<void> _loadGroups() async {
    try {
      // Check authentication first
      final isAuth = await _apiService.isAuthenticated();
      if (!isAuth) {
        throw Exception('Not authenticated. Please login first.');
      }

      print('🔄 Fetching groups from Backend...');

      // Call Backend API to get groups
      final response = await _apiService.get('/api/groups?page=1&size=20');

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'];

        // Parse the paginated response
        if (data != null && data['content'] != null) {
          final List<dynamic> groupsJson = data['content'];
          final groups = groupsJson
              .map((json) => Group.fromJson(json))
              .toList();

          setState(() {
            _recommendedGroups = groups;
          });

          print('✅ Groups loaded successfully: ${groups.length} groups');
        } else {
          print('⚠️ No groups found in response');
          setState(() {
            _recommendedGroups = [];
          });
        }
      } else {
        print('❌ Backend returned error: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _recommendedGroups = [];
        });
      }
    } catch (e) {
      print('❌ Error loading groups: $e');
      setState(() {
        _recommendedGroups = [];
      });
      rethrow;
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

  /// Refresh data
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

              // Search Bar
              SliverToBoxAdapter(
                child: HomeSearchBar(
                  onSearch: (query) {
                    // TODO: Implement search
                  },
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
                      GroupGridSection(
                        title: 'Recommend For You',
                        groups: _recommendedGroups,
                        onViewAll: () {
                          // TODO: Navigate to all groups
                        },
                        onGroupTap: (group) {
                          // TODO: Navigate to group details
                        },
                        onGroupJoin: (group) {
                          // TODO: Join group
                        },
                        onGroupFavorite: (group) {
                          // TODO: Toggle favorite
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
