import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'package:zipkart_firebase/core/routes/routes.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;
    final isDesktop = width >= 1000;

    return Scaffold(
      // backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Account',
          style: TextStyle(
            // color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(
                  Icons.logout,
                  // color: Colors.black87
              ),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isDesktop
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  // width: 340,
                  child: _ProfileHero(user: user),
                ),
                // const SizedBox(width: 32),
                Expanded(
                  child: _OptionsSection(
                    layout: _Layout.grid,
                    columns: 4,
                  ),
                ),
              ],
            )
                : ListView(
              children: [
                _ProfileHero(user: user),
                const SizedBox(height: 24),
                _OptionsSection(
                  layout: isMobile ? _Layout.list : _Layout.grid,
                  columns: isTablet ? 2 : 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PROFILE HERO
/// ------------------------------------------------------------
class _ProfileHero extends StatelessWidget {
  final dynamic user;

  const _ProfileHero({this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6E8CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  // backgroundColor: Colors.white,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName ?? 'User',
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.email != null)
                  Text(
                    user.email!,
                    style: const TextStyle(
                      // color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// OPTIONS SECTION (LIST OR GRID)
/// ------------------------------------------------------------
class _OptionsSection extends StatelessWidget {
  final _Layout layout;
  final int columns;

  const _OptionsSection({
    required this.layout,
    required this.columns,
  });

  static const items = [
    _Item(Icons.person_outline, 'Profile', 'Manage profile', AppRoutes.UserProfile),
    _Item(Icons.shopping_bag_outlined, 'Orders', 'Track orders', '/OrderDetail'),
    _Item(Icons.location_on_outlined, 'Address', 'Saved addresses', AppRoutes.Address),
    // _Item(Icons.payment_outlined, 'Payments', 'Cards & UPI', AppRoutes.Payment),
  ];

  @override
  Widget build(BuildContext context) {
    if (layout == _Layout.list) {
      return Column(
        children: items
            .map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionTile(item: e),
          ),
        )
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.2, // 🔥 FIXED HEIGHT ISSUE
      ),
      itemBuilder: (_, i) => _OptionTile(item: items[i]),
    );
  }
}

/// ------------------------------------------------------------
/// OPTION TILE
/// ------------------------------------------------------------
class _OptionTile extends StatelessWidget {
  final _Item item;

  const _OptionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(item.route),
      child: Container(
        height: 72, // 🔥 MOBILE HEIGHT FIX
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              // color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              // backgroundColor: Colors.blue.shade50,
              child: Icon(
                  item.icon,
                  // color: Colors.blue
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      // color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
                Icons.chevron_right,
                // color: Colors.grey
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// MODEL
/// ------------------------------------------------------------
enum _Layout { list, grid }

class _Item {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _Item(this.icon, this.title, this.subtitle, this.route);
}
