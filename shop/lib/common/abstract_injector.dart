import 'package:flutter/material.dart';
import 'package:shop/about/domain/abstract_about_repository.dart';
import 'package:shop/common/services/cloudinary_service.dart';
import 'package:shop/news/domain/abstract_news_repository.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';

abstract class AbstractInjector {

  late final AbstractProductRepository productRepository;
  late final AbstractProductGroupRepository productGroupRepository;
  late final AbstractNewsRepository newsRepository;
  late final AbstractAboutRepository aboutRepository;
  late final AbstractAboutRepository infoRepository;
  late final CloudinaryService cloudinaryService;

  AbstractInjector();

  /// Инициализация.
  Future<void> init();
}

class Injector extends InheritedWidget {
  const Injector({
    Key? key,
    required this.injector,
    required Widget child,
  }) : super(key: key, child: child);

  final AbstractInjector injector;

  static AbstractInjector of(BuildContext c) {
    return c.dependOnInheritedWidgetOfExactType<Injector>()!.injector;
  }

  @override
  bool updateShouldNotify(Injector oldWidget) => injector != oldWidget.injector;
}
