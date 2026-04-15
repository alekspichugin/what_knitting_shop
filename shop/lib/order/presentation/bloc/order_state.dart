part of 'order_cubit.dart';

enum OrderStatus { idle, loading, success, error }

class OrderState {
  const OrderState({
    this.status = OrderStatus.idle,
    this.errorMessage,
  });

  final OrderStatus status;
  final String? errorMessage;

  bool get isLoading => status == OrderStatus.loading;
  bool get isSuccess => status == OrderStatus.success;
  bool get isError => status == OrderStatus.error;
}
