import 'package:shop/about/domain/model/about_content.dart';

abstract class AbstractAboutRepository {
  Future<AboutContent> get();
  Future<void> save(AboutContent content);
}
