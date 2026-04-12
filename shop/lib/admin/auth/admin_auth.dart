import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Хранит состояние авторизации (true = вошёл).
/// ValueNotifier<bool> уже является ChangeNotifier — GoRouter
/// может использовать его как refreshListenable напрямую.
class AdminAuth extends InheritedNotifier<ValueNotifier<bool>> {
  const AdminAuth({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<bool> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminAuth>()!.notifier!;

  /// Войти через Firebase Auth. Возвращает null если успешно, иначе текст ошибки.
  static Future<String?> login(
      BuildContext context, String email, String pass) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      AdminAuth.of(context).value = true;
      return null;
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Неверный email или пароль',
        'invalid-email' => 'Некорректный email',
        'too-many-requests' => 'Слишком много попыток, попробуйте позже',
        _ => 'Ошибка входа: ${e.message}',
      };
    }
  }

  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    AdminAuth.of(context).value = false;
  }
}
