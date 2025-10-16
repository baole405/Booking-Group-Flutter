import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/category_filter_chip.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/color_filter_dot.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/group_recommendation_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/major_group_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/round_icon_button.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/section_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categories = ['All', 'MC', 'Dev', 'IB'];
  final List<Color> _colorFilters = [
    Colors.black,
    Colors.grey.shade800,
    Colors.grey.shade600,
    Colors.grey.shade400,
  ];

  int _selectedCategoryIndex = 0;
  int _selectedColorIndex = 0;

  Future<void> _handleLogout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onLogoutTap: _handleLogout,
              ),
              const SizedBox(height: 28),
              Text(
                'Search your dream team...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _SearchField(onTapFilter: () {}),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return CategoryFilterChip(
                            label: _categories[index],
                            isSelected: _selectedCategoryIndex == index,
                            onSelected: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: _categories.length,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: List.generate(
                      _colorFilters.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                        child: ColorFilterDot(
                          color: _colorFilters[index],
                          isSelected: _selectedColorIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedColorIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SectionHeader(
                title: 'Recommend For You',
                onActionTap: () {},
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recommendedGroups.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final group = _recommendedGroups[index];
                  return GroupRecommendationCard(
                    title: group.title,
                    needText: group.need,
                    tags: group.tags,
                    rating: group.rating,
                  );
                },
              ),
              const SizedBox(height: 32),
              SectionHeader(
                title: 'Relative to your major',
                onActionTap: () {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _majorGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final group = _majorGroups[index];
                    return MajorGroupCard(
                      title: group.title,
                      subtitle: group.subtitle,
                      icon: group.icon,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    this.onBackTap,
    required this.onLogoutTap,
  });

  final VoidCallback? onBackTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBackTap != null)
          RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: onBackTap,
          )
        else
          const SizedBox(width: 44, height: 44),
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/logo_fptu.png',
              height: 46,
            ),
          ),
        ),
        PopupMenuButton<_MenuAction>(
          onSelected: (value) {
            if (value == _MenuAction.logout) {
              onLogoutTap();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 46),
          itemBuilder: (context) => [
            PopupMenuItem<_MenuAction>(
              value: _MenuAction.logout,
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.grey.shade700, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

enum _MenuAction { logout }

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTapFilter});

  final VoidCallback onTapFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your dream team...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onTapFilter,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupInfo {
  const _GroupInfo({
    required this.title,
    required this.need,
    required this.tags,
    required this.rating,
  });

  final String title;
  final String need;
  final String tags;
  final double rating;
}

class _MajorInfo {
  const _MajorInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_GroupInfo> _recommendedGroups = [
  _GroupInfo(
    title: 'Group 1',
    need: 'Need 2 IT',
    tags: '2 IB, 2 MC',
    rating: 4.8,
  ),
  _GroupInfo(
    title: 'Group 2',
    need: 'Need 3 IT',
    tags: '1 MC',
    rating: 4.6,
  ),
  _GroupInfo(
    title: 'Group 3',
    need: 'Need 1 Designer',
    tags: '2 Dev, 1 MC',
    rating: 4.9,
  ),
  _GroupInfo(
    title: 'Group 4',
    need: 'Need 2 MC',
    tags: '1 Dev, 1 IB',
    rating: 4.7,
  ),
];

const List<_MajorInfo> _majorGroups = [
  _MajorInfo(
    title: 'Group 13',
    subtitle: '4 IT',
    icon: Icons.group,
  ),
  _MajorInfo(
    title: 'Group 21',
    subtitle: '3 MC',
    icon: Icons.people_alt_outlined,
  ),
  _MajorInfo(
    title: 'Group Sigma',
    subtitle: '4 Dev',
    icon: Icons.code,
  ),
];
