import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/presentation/bloc/cart_cubit.dart';
import 'package:shop/common/abstract_injector.dart';
import 'package:shop/di/di.dart';
import 'package:shop/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  FlutterError.onError = (FlutterErrorDetails details, {bool fatal = false}) {
    FlutterError.dumpErrorToConsole(details);
  };

  final injector = Di().injector;
  await injector.init();

  final router = createRouter(injector);

  runApp(
    BlocProvider(
      create: (_) => CartCubit(),
      child: Injector(
        injector: injector,
        child: App(router: router),
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'What knitting shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
