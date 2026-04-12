import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/about/presentation/bloc/about_cubit.dart';
import 'package:shop/about/presentation/bloc/about_editor_cubit.dart';
import 'package:shop/about/presentation/ui/admin/about_admin_page.dart';
import 'package:shop/about/presentation/ui/admin/about_editor_page.dart';
import 'package:shop/admin/ui/admin_shell.dart';
import 'package:shop/admin/ui/login_page.dart';
import 'package:shop/common/abstract_injector.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_cubit.dart';
import 'package:shop/news/presentation/ui/admin/news_admin_form_page.dart';
import 'package:shop/news/presentation/ui/admin/news_admin_list_page.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_cubit.dart';
import 'package:shop/product/presentation/ui/admin/product_admin_form_page.dart';
import 'package:shop/product/presentation/ui/admin/product_admin_list_page.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_cubit.dart';
import 'package:shop/product_group/presentation/ui/admin/group_admin_form_page.dart';
import 'package:shop/product_group/presentation/ui/admin/group_admin_list_page.dart';

GoRouter createAdminRouter(AbstractInjector injector, ValueNotifier<bool> auth) {
  return GoRouter(
    initialLocation: '/products',
    refreshListenable: auth,
    redirect: (context, state) {
      final onLogin = state.uri.path == '/login';
      if (!auth.value && !onLogin) return '/login';
      if (auth.value && onLogin) return '/products';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),

      ShellRoute(
        // Все кубиты живут здесь — список и форма делят один экземпляр.
        // Когда форма вызывает cubit.update()/create()/delete(), список
        // автоматически получает обновлённое состояние.
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductAdminCubit(injector.productRepository, injector.productGroupRepository)..load()),
            BlocProvider(create: (_) => GroupAdminCubit(injector.productGroupRepository)..load()),
            BlocProvider(create: (_) => NewsAdminCubit(injector.newsRepository)..load()),
            BlocProvider(create: (_) => AboutCubit(injector.aboutRepository)..load()),
            BlocProvider(create: (_) => AboutEditorCubit(injector.cloudinaryService)),
          ],
          child: AdminShell(child: child),
        ),
        routes: [
          // ── Products ──────────────────────────────────────────────────────
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductAdminListPage(),
            ),
          ),
          GoRoute(
            path: '/products/new',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductAdminFormPage(),
            ),
          ),
          GoRoute(
            path: '/products/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return NoTransitionPage(
                child: ProductAdminFormPage(productId: id),
              );
            },
          ),

          // ── Groups ────────────────────────────────────────────────────────
          GoRoute(
            path: '/groups',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GroupAdminListPage(),
            ),
          ),
          GoRoute(
            path: '/groups/new',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GroupAdminFormPage(),
            ),
          ),
          GoRoute(
            path: '/groups/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return NoTransitionPage(
                child: GroupAdminFormPage(groupId: id),
              );
            },
          ),

          // ── News ──────────────────────────────────────────────────────────
          GoRoute(
            path: '/news',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewsAdminListPage(),
            ),
          ),
          GoRoute(
            path: '/news/new',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewsAdminFormPage(),
            ),
          ),
          GoRoute(
            path: '/news/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return NoTransitionPage(
                child: NewsAdminFormPage(newsId: id),
              );
            },
          ),

          // ── About ─────────────────────────────────────────────────────────
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AboutAdminPage(),
            ),
          ),
          GoRoute(
            path: '/about/edit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AboutEditorPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
