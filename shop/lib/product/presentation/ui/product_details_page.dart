import 'package:flutter/material.dart';
import 'package:shop/common/cloudinary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/product/presentation/bloc/details/product_details_cubit.dart';
import 'package:shop/routes.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, this.groupId, this.groupTitle});

  final int? groupId;
  final String? groupTitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
          if (state.product == null) {
            return const Center(
              child: Text('Не удалось загрузить информацию о товаре!'),
            );
          }

          final product = state.product!;
          final cartCubit = context.read<CartCubit>();
          return ListView(
            children: [
              ContentBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
                    _Breadcrumb(
                      title: product.title.isNotEmpty
                          ? product.title
                          : 'Товар #${product.id + 1}',
                      groupId: groupId,
                      groupTitle: groupTitle,
                    ),
                    const Gap(24),
                    // Product layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image carousel
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _DetailsCarousel(imageIds: product.imageIds),
                        ),
                        const Gap(48),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title.isNotEmpty
                                    ? product.title
                                    : 'Товар #${product.id + 1}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Gap(16),
                              Text(
                                product.description.isNotEmpty
                                    ? product.description
                                    : 'Очаровательный вязаный медвежонок Тедди, созданный с любовью и заботой! Эта уникальная игрушка станет лучшим другом для вашего ребёнка или трогательным подарком для близкого человека.',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4B5563),
                                  height: 1.6,
                                ),
                              ),
                              const Gap(32),
                              const Divider(color: Color(0xFFE5E7EB)),
                              const Gap(24),
                              BlocBuilder<CartCubit, CartState>(
                                builder: (context, cartState) {
                                  final cartItem = cartState.items
                                      .where((i) => i.product.id == product.id)
                                      .firstOrNull;

                                  if (cartItem != null) {
                                    return Row(
                                      children: [
                                        SizedBox(
                                          height: 48,
                                          child: _DetailsQuantityRow(
                                            quantity: cartItem.quantity,
                                            onDecrement: () => cartCubit.decrement(product.id),
                                            onIncrement: () => cartCubit.increment(product.id),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      SizedBox(
                                        height: 48,
                                        child: FilledButton.icon(
                                          onPressed: () => cartCubit.add(product),
                                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                                          label: const Text(
                                            'Добавить в корзину',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: const Color(0xFF7C3AED),
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(48),
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

class _DetailsQuantityRow extends StatelessWidget {
  const _DetailsQuantityRow({
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
        border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn(icon: Icons.remove, onTap: onDecrement),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            _Btn(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
      ),
    );
  }
}

// =============================================================================

class _DetailsCarousel extends StatefulWidget {
  const _DetailsCarousel({required this.imageIds});
  final List<String> imageIds;

  @override
  State<_DetailsCarousel> createState() => _DetailsCarouselState();
}

class _DetailsCarouselState extends State<_DetailsCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageIds.isEmpty) {
      return Container(
        width: 480,
        height: 420,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.image_outlined, size: 64, color: Color(0xFFD1D5DB)),
      );
    }

    return SizedBox(
      width: 480,
      height: 420,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.imageIds.length,
            itemBuilder: (_, i) => Image.network(
              cloudinaryUrl(widget.imageIds[i], size: CloudinarySize.medium),
              width: 480,
              height: 420,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      width: 480,
                      height: 420,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                width: 480,
                height: 420,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image_outlined, size: 64, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
          // Стрелки навигации
          if (widget.imageIds.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: _current > 0
                      ? () => _controller.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_right,
                  onTap: _current < widget.imageIds.length - 1
                      ? () => _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ),
            ),
            // Точки
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageIds.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap != null ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// =============================================================================

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.title, this.groupId, this.groupTitle});

  final String title;
  final int? groupId;
  final String? groupTitle;

  static const _chevron = Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
  );

  static const _linkStyle = TextStyle(
    fontSize: 13,
    color: Color(0xFF7C3AED),
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(kHomeRoute),
          child: const MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text('Главная', style: _linkStyle),
          ),
        ),
        if (groupId != null && groupTitle != null) ...[
          _chevron,
          GestureDetector(
            onTap: () => context.go('$kProductGroupRoute/$groupId'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(groupTitle!, style: _linkStyle),
            ),
          ),
        ],
        _chevron,
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
