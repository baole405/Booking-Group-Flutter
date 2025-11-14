import 'package:flutter/material.dart';

/// Header widget with FPT logo and menu button
class HomeHeader extends StatelessWidget {
  final String? userEmail;
  final String? userName;
  final String? semesterName;
  final bool isSemesterLoading;
  final bool hasAttemptedSemesterLoad;

  const HomeHeader({
    super.key,
    this.userEmail,
    this.userName,
    this.semesterName,
    this.isSemesterLoading = false,
    this.hasAttemptedSemesterLoad = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSemester = semesterName?.isNotEmpty == true;
    final showLoadingState =
        isSemesterLoading || (!hasAttemptedSemesterLoad && !hasSemester);
    final semesterLabel = showLoadingState
        ? 'Loading...'
        : hasSemester
        ? semesterName!
        : 'Loading';

    final resolvedName = (userName?.trim().isNotEmpty ?? false)
        ? userName!.trim()
        : (userEmail != null && userEmail!.isNotEmpty
              ? userEmail!.split('@').first
              : 'ban');

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
                Expanded(
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
                        semesterLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xin chao,',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  resolvedName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
