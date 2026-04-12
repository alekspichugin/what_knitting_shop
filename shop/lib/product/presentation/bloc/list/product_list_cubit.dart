import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:shop/common/abstract_state.dart';

part 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {

  static const kCTag = 'ProductListCubit';

  ProductListCubit(
      this._authenticationCubit,
      ) : super(ProductListState()) {
    _authenticationCubitSubscription = _authenticationCubit.stream
        .listen(_onAuthenticationStateChanged);
  }

  final AuthenticationCubit _authenticationCubit;

  bool _needWarnUser = true;

  StreamSubscription? _isTimeCorrectChangeSubscription;
  StreamSubscription? _authenticationCubitSubscription;

  // ===========================================================================
  // Cubit<CheckTimeAbstractState>
  // ===========================================================================

  @override
  Future<void> close() {
    _isTimeCorrectChangeSubscription?.cancel();
    _isTimeCorrectChangeSubscription = null;

    _authenticationCubitSubscription?.cancel();
    _authenticationCubitSubscription = null;
    return super.close();
  }

  // ===========================================================================

}
