import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/admin/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login(String login, String password) {
    emit(AuthError('Неверный логин или пароль'));
  }

  void logout() => emit(AuthInitial());
}
