import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
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
      body: Column(
        children: [
          const _WebHeader(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// =============================================================================
// ContentBox — ограничивает контент по ширине
// =============================================================================

class ContentBox extends StatelessWidget {
  const ContentBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
// Веб-хедер
// =============================================================================

class _WebHeader extends StatelessWidget {
  const _WebHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  const _Logo(),
                  const SizedBox(width: 48),
                  const _NavLink(label: 'Каталог', route: kCatalogRoute),
                  const SizedBox(width: 24),
                  const _NavLink(label: 'О нас', route: kAboutRoute),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const SizedBox(width: 8),
                  if (hasItems)
                    Text(
                      '${state.totalCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  else
                    const Text(
                      'Корзина',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
