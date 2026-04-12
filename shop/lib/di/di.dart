import 'package:shop/common/abstract_injector.dart';
import 'package:shop/di/injector.dart';

class Di {
  Di._();

  factory Di() => _instance;

  static final Di _instance = Di._();

  late final injector = _createInjector();

  // ===========================================================================

  AbstractInjector _createInjector() {
    return RemoteInjector();
  }
}
