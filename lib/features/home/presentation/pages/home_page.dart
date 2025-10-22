import 'dart:convert';

import 'package:booking_group_flutter/core/services/api_service.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 🏠 Home Page - Redesigned with clean architecture
///
/// Features:
/// - Auto load groups on login (no hot restart needed)
/// - Clear layout separation
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
              // 1️⃣ Header with Logo and Menu
              _buildHeader(),

              // 2️⃣ Search Bar
              _buildSearchBar(),

              // 3️⃣ Main Content
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else
                _buildContent(),
            ],
          ),
        ),
      ),

      // 4️⃣ Bottom Navigation
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================
  // 📱 UI Components
  // ============================================

  /// Header with logo and menu
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              'assets/images/fpt_logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'FPT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6600),
                  ),
                );
              },
            ),

            // Menu button
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text(_userEmail ?? 'User'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  onTap: _handleLogout,
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Search bar
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search groups...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: (value) {
            // TODO: Implement search
          },
        ),
      ),
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  /// Error state
  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Main content
  Widget _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Recommend For You Section (only section)
        _buildSection(title: 'Recommend For You', groups: _recommendedGroups),

        const SizedBox(height: 80), // Space for bottom nav
      ]),
    );
  }

  /// Section with title and group cards
  Widget _buildSection({required String title, required List<Group> groups}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: View all
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Group cards
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No groups found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.85, // Increased from 0.75 to make cards taller
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: groups.length > 4 ? 4 : groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupCard(group);
            },
          ),
      ],
    );
  }

  /// Group card
  Widget _buildGroupCard(Group group) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.group, size: 48, color: Colors.grey),
            ),
          ),

          // Group info
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Like button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        group.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Join button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Join group
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Join now',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation bar
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, true),
          _buildNavItem(Icons.search, false),
          _buildNavItem(Icons.notifications, false),
          _buildNavItem(Icons.person, false),
        ],
      ),
    );
  }

  /// Bottom navigation item
  Widget _buildNavItem(IconData icon, bool isActive) {
    return IconButton(
      icon: Icon(icon, color: isActive ? Colors.white : Colors.grey[600]),
      onPressed: () {
        // TODO: Navigate
      },
    );
  }
}
