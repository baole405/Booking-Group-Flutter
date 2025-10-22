import 'package:flutter/material.dart';

/// Header widget with FPT logo and menu button
class HomeHeader extends StatelessWidget {
  final String? userEmail;
  final VoidCallback onLogout;

  const HomeHeader({super.key, this.userEmail, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                child: Text(userEmail ?? 'User'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                onTap: onLogout,
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
    );
  }
}
