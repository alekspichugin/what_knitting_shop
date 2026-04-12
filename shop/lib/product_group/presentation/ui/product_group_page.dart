import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intersperse/intersperse.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
import 'package:shop/common/cloudinary.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';
import 'package:shop/product_group/presentation/bloc/product_group_cubit.dart';
import 'package:shop/routes.dart';

class ProductGroupPage extends StatelessWidget {
  const ProductGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductGroupCubit, ProductGroupState>(
      builder: (context, state) {
        // Предзагружаем thumbnail-ы как только список пришёл
        for (final p in state.products) {
          if (p.imageId.isNotEmpty) {
            precacheImage(
              NetworkImage(cloudinaryUrl(p.imageId, size: CloudinarySize.thumbnail)),
              context,
            );
          }
        }

        return state.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ContentBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb
                        _Breadcrumb(title: state.groupTitle ?? ''),
                        const Gap(16),
                        // Page title
                        Text(
                          state.groupTitle ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(24),
                        // Product grid
                        _ProductGrid(products: state.products),
                        const Gap(32),
                      ],
                    ),
                  ),
                ],
              );
      },
    );
  }
}

// =============================================================================

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(kHomeRoute),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Главная',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

// =============================================================================

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<ViewProduct> products;

  @override
  Widget build(BuildContext context) {
    final rows = products.slices(4);

    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildRow(context, row),
              ))
          .toList(),
    );
  }

  Widget _buildRow(BuildContext context, List<ViewProduct> products) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...products
            .map<Widget>((p) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _ProductCard(product: p),
                  ),
                ))
            .intersperse(const SizedBox()),
        if (products.length < 4)
          ...List.generate(
            4 - products.length,
            (_) => const Expanded(child: SizedBox()),
          ),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});

  final ViewProduct product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final title = widget.product.title.isNotEmpty
        ? widget.product.title
        : 'Товар #${widget.product.id + 1}';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          final s = context.read<ProductGroupCubit>().state;
          final groupId = s.groupId;
          final groupTitle = s.groupTitle ?? '';
          final uri = groupId != null
              ? '$kProductDetailsRoute/${widget.product.id}'
                '?groupId=$groupId&groupTitle=${Uri.encodeQueryComponent(groupTitle)}'
              : '$kProductDetailsRoute/${widget.product.id}';
          context.push(uri);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  transform: _hovered
                      ? (Matrix4.identity()..translate(0.0, -3.0))
                      : Matrix4.identity(),
                  clipBehavior: Clip.hardEdge,
                  child: _ImageCarousel(imageIds: widget.product.imageIds),
                ),
                // Кнопка корзины / счётчик
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      final cartItem = cartState.items
                          .where((i) => i.product.id == widget.product.id)
                          .firstOrNull;

                      if (cartItem != null) {
                        return _QuantityChip(
                          quantity: cartItem.quantity,
                          onDecrement: () =>
                              cartCubit.decrement(widget.product.id),
                          onIncrement: () =>
                              cartCubit.increment(widget.product.id),
                        );
                      }

                      return _AddToCartChip(
                        onTap: () => cartCubit.add(widget.product),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF111827),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(4),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

class _AddToCartChip extends StatelessWidget {
  const _AddToCartChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_shopping_cart, size: 16, color: Color(0xFF7C3AED)),
            SizedBox(width: 6),
            Text(
              'В корзину',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

class _QuantityChip extends StatelessWidget {
  const _QuantityChip({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChipBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _ChipBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  const _ChipBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
      ),
    );
  }
}

// =============================================================================

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.imageIds});
  final List<String> imageIds;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _current = 0;
  bool _hovered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prev() {
    if (_current > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  void _next() {
    if (_current < widget.imageIds.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageIds.isEmpty) {
      return Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DB)),
        ),
      );
    }

    final hasMultiple = widget.imageIds.length > 1;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.imageIds.length,
            itemBuilder: (_, i) => Image.network(
              cloudinaryUrl(widget.imageIds[i], size: CloudinarySize.medium),
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),

          // Стрелка влево
          if (hasMultiple)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _hovered && _current > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: _ArrowButton(icon: Icons.chevron_left, onTap: _prev),
                ),
              ),
            ),

          // Стрелка вправо
          if (hasMultiple)
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _hovered && _current < widget.imageIds.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: _ArrowButton(icon: Icons.chevron_right, onTap: _next),
                ),
              ),
            ),

          // Точки-индикаторы
          if (hasMultiple)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageIds.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _current == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
