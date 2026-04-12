import 'package:flutter/material.dart';
import 'package:shop/cart/domain/model/cart_item.dart';
import 'package:shop/common/ui/product_tile.dart';

export 'package:shop/common/ui/product_tile.dart' show ProductTile;

enum CartItemTileSize { large, small }

/// Cart-specific tile built on top of [ProductTile].
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    this.size = CartItemTileSize.large,
    this.trailing,
  });

  final CartItem item;
  final CartItemTileSize size;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final thumbSize = size == CartItemTileSize.large ? 80.0 : 48.0;
    final radius = size == CartItemTileSize.large ? 10.0 : 8.0;
    final title = item.product.title.isNotEmpty
        ? item.product.title
        : 'Товар #${item.product.id + 1}';

    return ProductTile(
      imageIds: item.product.imageIds,
      title: title,
      thumbSize: thumbSize,
      thumbRadius: radius,
      trailing: trailing,
    );
  }
}
