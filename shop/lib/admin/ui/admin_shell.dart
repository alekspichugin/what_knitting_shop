import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/admin/auth/admin_auth.dart';

const _kSidebarWidth = 220.0;
const _kSidebarBg = Color(0xFF1E1B4B);
const _kSidebarActiveItem = Color(0xFF4C1D95);
const _kTopBarHeight = 56.0;

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Row(
              children: [
                _Sidebar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kTopBarHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(Icons.interests_rounded, color: Color(0xFF7C3AED), size: 24),
          const SizedBox(width: 10),
          const Text(
            'What Knitting · Панель администратора',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => AdminAuth.logout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Выйти'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: _kSidebarWidth,
      color: _kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _SidebarItem(
            icon: Icons.inventory_2_outlined,
            label: 'Товары',
            route: '/products',
            active: location.startsWith('/products'),
          ),
          _SidebarItem(
            icon: Icons.category_outlined,
            label: 'Группы',
            route: '/groups',
            active: location.startsWith('/groups'),
          ),
          _SidebarItem(
            icon: Icons.article_outlined,
            label: 'Информация',
            route: '/news',
            active: location.startsWith('/news'),
          ),
          _SidebarItem(
            icon: Icons.info_outline,
            label: 'О нас',
            route: '/about',
            active: location.startsWith('/about'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: active ? _kSidebarActiveItem : Colors.transparent,
          border: active
              ? const Border(left: BorderSide(color: Color(0xFFA78BFA), width: 3))
              : const Border(left: BorderSide(color: Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : Colors.white60),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
