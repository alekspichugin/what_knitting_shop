import 'package:equatable/equatable.dart';

abstract class AbstractState extends Equatable {
  const AbstractState({
    this.throwable,
    bool? isCritical,
  }) : isCritical = isCritical ?? false;

  /// Если есть ошибка.
  final dynamic throwable;

  /// Если ошибка критическая.
  final bool isCritical;

  bool get hasThrowable => throwable != null;

  // ===========================================================================
  // Equatable
  // ===========================================================================

  @override
  List<dynamic> get props => [throwable, isCritical];

  // ===========================================================================
  // Object
  // ===========================================================================

  @override
  String toString() =>
      '$runtimeType { throwable: $throwable isCritical: $isCritical}';
}