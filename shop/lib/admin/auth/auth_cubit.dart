import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/admin/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login(String login, String password) {
    if (login == 'admin' && password == 'admin') {
      emit(AuthAuthenticated());
    } else {
      emit(AuthError('Неверный логин или пароль'));
    }
  }

  void logout() => emit(AuthInitial());
}
