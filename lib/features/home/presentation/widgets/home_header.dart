import 'package:flutter/material.dart';

/// Header widget with FPT logo and menu button
class HomeHeader extends StatelessWidget {
  final String? userEmail;
  final VoidCallback onLogout;
  final String? semesterName;
  final bool isSemesterLoading;

  const HomeHeader({
    super.key,
    this.userEmail,
    required this.onLogout,
    this.semesterName,
    this.isSemesterLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Active semester',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSemesterLoading
                            ? 'Loading...'
                            : (semesterName?.isNotEmpty == true
                                  ? semesterName!
                                  : 'No semester'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
