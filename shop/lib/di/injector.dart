import 'package:firebase_core/firebase_core.dart';
import 'package:shop/about/data/repository/firebase_about_repository.dart';
import 'package:shop/common/services/cloudinary_service.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/news/data/repository/firebase_news_repository.dart';
import 'package:shop/product/data/repository/firebase_product_repository.dart';
import 'package:shop/product_group/data/repository/firebase_product_group_repository.dart';
import 'package:synchronized/synchronized.dart';

import '/common/abstract_injector.dart';

class RemoteInjector extends AbstractInjector {
  RemoteInjector();

  static final _lock = Lock();
  bool _isInit = false;

  // ===========================================================================
  // AbstractInjector
  // ===========================================================================

  @override
  Future<void> init() async {
    if (_isInit) return;
    return _lock.synchronized(() async {
      if (_isInit) return;
      return _init().then((v) => _isInit = true);
    });
  }

  // ===========================================================================

  Future<void> _init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    productRepository = FirebaseProductRepository();
    productGroupRepository = FirebaseProductGroupRepository();
    newsRepository = FirebaseNewsRepository();
    aboutRepository = FirebaseAboutRepository();
    cloudinaryService = const CloudinaryService();
  }
}
