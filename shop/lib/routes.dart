import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/cart/presentation/ui/cart_page.dart';
import 'package:shop/common/abstract_injector.dart';
import 'package:shop/common/ui/app_shell.dart';
import 'package:shop/home/presentation/bloc/home_cubit.dart';
import 'package:shop/home/presentation/ui/catalog_page.dart';
import 'package:shop/home/presentation/ui/home_page.dart';
import 'package:shop/order/presentation/ui/order_page.dart';
import 'package:shop/product/presentation/bloc/details/product_details_cubit.dart';
import 'package:shop/product/presentation/bloc/list/product_list_cubit.dart';
import 'package:shop/product/presentation/ui/product_details_page.dart';
import 'package:shop/product/presentation/ui/product_list_page.dart';
import 'package:shop/product_group/presentation/bloc/product_group_cubit.dart';
import 'package:shop/about/presentation/bloc/about_cubit.dart';
import 'package:shop/about/presentation/ui/about_page.dart';
import 'package:shop/product_group/presentation/ui/product_group_page.dart';

// URL пути
const kHomeRoute = '/';
const kCatalogRoute = '/catalog';
const kProductGroupRoute = '/product/group';
const kProductDetailsRoute = '/product/details';
const kProductListRoute = '/product/list';
const kProductBasketRoute = '/cart';
const kOrderRoute = '/order';
const kAboutRoute = '/about';

// =============================================================================

GoRouter createRouter(AbstractInjector injector) {
  return GoRouter(
    initialLocation: kHomeRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: kHomeRoute,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => HomeCubit(
                  injector.productGroupRepository,
                  injector.newsRepository,
                )..load(),
                child: const HomePage(),
              ),
            ),
          ),

          GoRoute(
            path: kCatalogRoute,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => HomeCubit(
                  injector.productGroupRepository,
                  injector.newsRepository,
                )..load(),
                child: const CatalogPage(),
              ),
            ),
          ),

          GoRoute(
            path: '$kProductGroupRoute/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => ProductGroupCubit(
                    injector.productGroupRepository,
                    injector.productRepository,
                    id,
                  )..load(),
                  child: const ProductGroupPage(),
                ),
              );
            },
          ),

          GoRoute(
            path: '$kProductDetailsRoute/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
              final groupId =
                  int.tryParse(state.uri.queryParameters['groupId'] ?? '');
              final groupTitle = state.uri.queryParameters['groupTitle'];
              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => ProductDetailsCubit(
                    injector.productRepository,
                    id,
                  )..load(),
                  child: ProductDetailsPage(
                      groupId: groupId, groupTitle: groupTitle),
                ),
              );
            },
          ),

          GoRoute(
            path: kProductListRoute,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) =>
                    ProductListCubit(injector.productRepository)..load(),
                child: ProductListPage(),
              ),
            ),
          ),

          GoRoute(
            path: kProductBasketRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartPage()),
          ),

          GoRoute(
            path: kOrderRoute,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrderPage()),
          ),

          GoRoute(
            path: kAboutRoute,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => AboutCubit(injector.aboutRepository)..load(),
                child: const AboutPage(),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
