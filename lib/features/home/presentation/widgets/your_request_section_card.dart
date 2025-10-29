import 'package:flutter/material.dart';

/// Your Request Section Card - Similar style to Groups/Your Group cards
class YourRequestSectionCard extends StatelessWidget {
  final int requestCount;
  final VoidCallback onTap;
  final String? latestGroupTitle;
  final String? latestStatusLabel;
  final String? latestTimeLabel;
  final bool showLatestRequestHighlight;

  const YourRequestSectionCard({
    super.key,
    required this.requestCount,
    required this.onTap,
    this.latestGroupTitle,
    this.latestStatusLabel,
    this.latestTimeLabel,
    this.showLatestRequestHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B5CF6), // Purple
              const Color(0xFF8B5CF6).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circle decoration
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      if (requestCount > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            child: Center(
                              child: Text(
                                requestCount > 99 ? '99+' : '$requestCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Your Request',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    requestCount > 0
                        ? '$requestCount yêu cầu đang chờ'
                        : 'Chưa có yêu cầu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (showLatestRequestHighlight && latestGroupTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.group_add_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bạn vừa gửi yêu cầu tới',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    latestGroupTitle!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (latestStatusLabel != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        latestStatusLabel!,
                                        style: TextStyle(
                                          color: Colors.orange.shade100,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (latestTimeLabel != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        latestTimeLabel!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
