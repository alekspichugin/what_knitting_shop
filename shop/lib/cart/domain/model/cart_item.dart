import 'package:shop/product/presentation/bloc/model/view_product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final ViewProduct product;
  final int quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
      );
}
