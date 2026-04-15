import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/admin/auth/admin_auth.dart';
import 'package:shop/common/breakpoints.dart';

const _kSidebarWidth = 220.0;
const _kSidebarBg = Color(0xFF1E1B4B);
const _kSidebarActiveItem = Color(0xFF4C1D95);
const _kTopBarHeight = 56.0;

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: mobile
          ? Drawer(
              backgroundColor: _kSidebarBg,
              child: _SidebarContent(),
            )
          : null,
      body: Column(
        children: [
          _TopBar(showMenuButton: mobile),
          Expanded(
            child: mobile
                ? child
                : Row(
                    children: [
                      SizedBox(
                        width: _kSidebarWidth,
                        child: ColoredBox(
                          color: _kSidebarBg,
                          child: _SidebarContent(),
                        ),
                      ),
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
  const _TopBar({required this.showMenuButton});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kTopBarHeight,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showMenuButton)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF1E1B4B)),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Меню',
              ),
            )
          else
            const Icon(Icons.interests_rounded, color: Color(0xFF7C3AED), size: 24),
          const SizedBox(width: 10),
          if (!showMenuButton)
            const Text(
              'What Knitting · Панель администратора',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1B4B),
              ),
            )
          else
            const Text(
              'What Knitting',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1B4B),
              ),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => AdminAuth.logout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: showMenuButton ? const SizedBox.shrink() : const Text('Выйти'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar content ──────────────────────────────────────────────────────────

class _SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Column(
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
          route: '/info',
          active: location.startsWith('/info'),
        ),
        _SidebarItem(
          icon: Icons.info_outline,
          label: 'О нас',
          route: '/about',
          active: location.startsWith('/about'),
        ),
      ],
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
      onTap: () {
        // Закрываем drawer если открыт
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
        context.go(route);
      },
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
