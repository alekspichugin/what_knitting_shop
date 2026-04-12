import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/cart/domain/model/cart_item.dart';
import 'package:shop/cart/presentation/bloc/cart_state.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';
import 'package:web/web.dart' as web;

export 'cart_state.dart';

const _kStorageKey = 'cart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState()) {
    _loadFromStorage();
  }

  void add(ViewProduct product) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    _emitAndSave(items);
  }

  void increment(int productId) => _updateQuantity(productId, 1);

  void decrement(int productId) => _updateQuantity(productId, -1);

  void remove(int productId) {
    _emitAndSave(
      state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void clear() {
    _emitAndSave([]);
  }

  void _updateQuantity(int productId, int delta) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final newQty = items[idx].quantity + delta;
    if (newQty <= 0) {
      items.removeAt(idx);
    } else {
      items[idx] = items[idx].copyWith(quantity: newQty);
    }
    _emitAndSave(items);
  }

  void _emitAndSave(List<CartItem> items) {
    emit(state.copyWith(items: items));
    _saveToStorage(items);
  }

  void _saveToStorage(List<CartItem> items) {
    try {
      final json = jsonEncode(items.map((i) => {
        'id': i.product.id,
        'title': i.product.title,
        'description': i.product.description,
        'imageIds': i.product.imageIds,
        'quantity': i.quantity,
      }).toList());
      web.window.localStorage.setItem(_kStorageKey, json);
    } catch (_) {}
  }

  void _loadFromStorage() {
    try {
      final raw = web.window.localStorage.getItem(_kStorageKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list.map((e) {
        final map = e as Map<String, dynamic>;
        return CartItem(
          product: ViewProduct(
            id: map['id'] as int,
            title: map['title'] as String? ?? '',
            description: map['description'] as String? ?? '',
            imageIds: (map['imageIds'] as List<dynamic>?)
                    ?.cast<String>() ??
                const [],
          ),
          quantity: map['quantity'] as int,
        );
      }).toList();
      emit(state.copyWith(items: items));
    } catch (_) {}
  }
}
