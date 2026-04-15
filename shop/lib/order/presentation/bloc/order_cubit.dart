import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/cart/domain/model/cart_item.dart';
import 'package:shop/order/data/telegram_service.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit(this._telegram) : super(const OrderState());

  final TelegramService _telegram;

  Future<void> submit({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required List<CartItem> items,
  }) async {
    emit(const OrderState(status: OrderStatus.loading));
    try {
      final text = _buildMessage(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        items: items,
      );
      await _telegram.sendMessage(text);
      emit(const OrderState(status: OrderStatus.success));
    } catch (e) {
      emit(OrderState(status: OrderStatus.error, errorMessage: e.toString()));
    }
  }

  void reset() => emit(const OrderState());

  String _buildMessage({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required List<CartItem> items,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<b>🛍 Новый заказ</b>');
    buffer.writeln();
    buffer.writeln('<b>Покупатель:</b> $firstName $lastName');
    buffer.writeln('<b>Телефон:</b> $phone');
    buffer.writeln('<b>Адрес:</b> $address');
    buffer.writeln();
    buffer.writeln('<b>Состав заказа:</b>');

    double total = 0;
    for (final item in items) {
      final linePrice = item.product.price * item.quantity;
      total += linePrice;
      final priceStr = linePrice > 0
          ? '  —  ${linePrice.toStringAsFixed(0)} ₽'
          : '';
      buffer.writeln('• ${item.product.title} × ${item.quantity}$priceStr');
    }

    if (total > 0) {
      buffer.writeln();
      buffer.writeln('<b>Итого: ${total.toStringAsFixed(0)} ₽</b>');
    }

    return buffer.toString();
  }
}
