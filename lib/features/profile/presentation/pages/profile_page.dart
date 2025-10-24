import 'dart:convert';

import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  String? _googleAvatar;
  String? _googleName;
  String? _googleEmail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Lấy thông tin từ Firebase Auth (Google Sign-In)
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _googleAvatar = firebaseUser.photoURL;
        _googleName = firebaseUser.displayName;
        _googleEmail = firebaseUser.email;
        debugPrint('✅ Firebase User: $_googleName ($_googleEmail)');
        debugPrint('✅ Avatar URL: $_googleAvatar');
      } else {
        // Fallback: Thử lấy từ GoogleSignIn nếu Firebase không có
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signInSilently();
        if (googleUser != null) {
          _googleAvatar = googleUser.photoUrl;
          _googleName = googleUser.displayName;
          _googleEmail = googleUser.email;
          debugPrint('✅ Google User: $_googleName ($_googleEmail)');
        }
      }

      // 2. Lấy thông tin từ Backend API (major, studentCode, etc.)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');

      if (token != null) {
        try {
          final response = await http.get(
            Uri.parse(ApiConstants.myInfoUrl),
            headers: ApiConstants.authHeaders(token),
          );

          debugPrint('📊 Profile API Response Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final Map<String, dynamic> jsonResponse = json.decode(
              response.body,
            );
            final data = jsonResponse['data'];

            if (data != null) {
              _userProfile = UserProfile.fromJson(data);
              debugPrint('✅ Backend profile loaded: ${_userProfile!.fullName}');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Backend API error (continuing with Google info): $e');
        }
      }

      // 3. Hiển thị thông tin (ưu tiên Google info cho avatar & name)
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Đăng xuất Google
      await GoogleSignIn().signOut();
      // Đăng xuất Firebase
      await FirebaseAuth.instance.signOut();
      // Xóa token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bearer_token');
      await prefs.remove('user_email');

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    // Ưu tiên thông tin từ Google
    final displayName = _googleName ?? _userProfile?.fullName ?? 'Người dùng';
    final displayEmail = _googleEmail ?? _userProfile?.email ?? '';
    final displayAvatar = _googleAvatar ?? _userProfile?.avatarUrl;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Profile Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Thông tin người dùng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: displayAvatar != null
                            ? NetworkImage(displayAvatar)
                            : null,
                        child: displayAvatar == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Student Code or identifier
                Text(
                  _userProfile?.identifier ?? 'Không rõ mã số',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // Email
                _ProfileInfoRow(label: 'Email', value: displayEmail),
                const SizedBox(height: 16),
                // Major
                if (_userProfile?.major != null)
                  _ProfileInfoRow(
                    label: 'Chuyên ngành',
                    value: _userProfile!.major!.name,
                  ),
                const SizedBox(height: 24),
                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chức năng cập nhật thông tin đang phát triển',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cập nhật thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
