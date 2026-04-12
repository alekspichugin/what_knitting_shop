import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/admin/auth/admin_auth.dart';
import 'package:shop/admin/routes.dart';
import 'package:shop/common/abstract_injector.dart';
import 'package:shop/di/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final injector = Di().injector;
  await injector.init();

  // Firebase Auth сохраняет сессию в браузере — currentUser != null после перезагрузки
  final auth = ValueNotifier<bool>(FirebaseAuth.instance.currentUser != null);

  runApp(
    AdminAuth(
      notifier: auth,
      child: Injector(
        injector: injector,
        child: AdminApp(router: createAdminRouter(injector, auth)),
      ),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'What Knitting · Админ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
