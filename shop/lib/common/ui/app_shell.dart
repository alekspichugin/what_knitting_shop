import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
import 'package:shop/common/breakpoints.dart';
import 'package:shop/routes.dart';

const _kBrandColor = Color(0xFF7C3AED);
const _kMaxWidth = 1280.0;

// =============================================================================
// AppShell — общая обёртка для всех страниц
// =============================================================================

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF9FAFB),
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: context.isMobile ? const _MobileDrawer() : null,
      body: Column(
        children: [
          const _AppHeader(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// =============================================================================
// ContentBox — ограничивает контент по ширине, адаптивный padding
// =============================================================================

class ContentBox extends StatelessWidget {
  const ContentBox({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final hPad = context.responsive<double>(mobile: 16, tablet: 24, desktop: 32);
    final effectivePadding = padding ??
        EdgeInsets.symmetric(horizontal: hPad, vertical: 24);

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
// Хедер — десктоп: nav-ссылки; мобиль: hamburger
// =============================================================================

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final hPad = context.responsive<double>(mobile: 16, tablet: 24, desktop: 32);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Row(
                children: [
                  if (mobile)
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF374151)),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        tooltip: 'Меню',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  if (mobile) const SizedBox(width: 12),
                  const _Logo(),
                  if (!mobile) ...[
                    const SizedBox(width: 40),
                    const _NavLink(label: 'Каталог', route: kCatalogRoute),
                  ],
                  const Spacer(),
                  const _CartButton(),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

// =============================================================================
// Мобильный Drawer
// =============================================================================

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const _Logo(),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.grid_view_rounded,
              label: 'Каталог',
              route: kCatalogRoute,
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_outlined,
              label: 'Корзина',
              route: kProductBasketRoute,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: _kBrandColor, size: 20),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}

// =============================================================================

class _Logo extends StatefulWidget {
  const _Logo();

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(kHomeRoute),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _kBrandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.interests_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: _hovered ? _kBrandColor : const Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              child: const Text('What Knitting'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.route});

  final String label;
  final String route;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovered ? _kBrandColor : const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

// =============================================================================

class _CartButton extends StatefulWidget {
  const _CartButton();

  @override
  State<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<_CartButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final hasItems = state.totalCount > 0;
        final mobile = context.isMobile;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: () {
              final current = GoRouterState.of(context).uri.path;
              if (current != kProductBasketRoute) {
                context.push(kProductBasketRoute);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 10 : 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: hasItems
                    ? _kBrandColor
                    : (_hovered ? const Color(0xFFF3F4F6) : Colors.transparent),
                border: Border.all(
                  color: hasItems
                      ? _kBrandColor
                      : (_hovered
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFFE5E7EB)),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color: hasItems ? Colors.white : const Color(0xFF374151),
                  ),
                  if (hasItems) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${state.totalCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ] else if (!mobile) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Корзина',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
