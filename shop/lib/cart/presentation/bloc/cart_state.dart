import 'package:shop/cart/domain/model/cart_item.dart';

class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get totalCount => items.fold(0, (s, i) => s + i.quantity);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}
