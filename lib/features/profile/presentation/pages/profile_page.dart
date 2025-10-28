import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/features/auth/application/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () => context.read<SessionController>().reloadProfile(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<SessionController>(
        builder: (context, session, _) {
          final profile = session.currentUser;
          if (session.status == SessionStatus.loading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profile == null) {
            return _EmptyProfile(onRetry: () => session.reloadProfile());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      profile.fullName?.isNotEmpty == true
                          ? profile.fullName![0].toUpperCase()
                          : profile.email[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.fullName ?? profile.email,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileTile(
                  label: 'Email',
                  value: profile.email,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _ProfileTile(
                  label: 'Student code',
                  value: profile.studentCode ?? 'Not provided',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _ProfileTile(
                  label: 'Major',
                  value: profile.majorName ?? 'Please update your major',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                _ProfileTile(
                  label: 'Current group',
                  value: profile.group?.title ?? 'Not in a group',
                  icon: Icons.group_outlined,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.read<SessionController>().signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'We were unable to load your profile.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
