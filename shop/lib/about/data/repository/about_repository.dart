import 'package:shop/about/domain/abstract_about_repository.dart';
import 'package:shop/about/domain/model/about_content.dart';

class AboutRepository implements AbstractAboutRepository {
  AboutContent _content = AboutContent(rows: [
    AboutRow(
      id: '1',
      blocks: [
        AboutBlock(id: '1', type: AboutBlockType.heading, content: 'Кто мы'),
      ],
    ),
    AboutRow(
      id: '2',
      blocks: [
        AboutBlock(
          id: '2',
          type: AboutBlockType.text,
          content: 'What Knitting — магазин товаров для вязания.',
        ),
      ],
    ),
  ]);

  @override
  Future<AboutContent> get() async => _content;

  @override
  Future<void> save(AboutContent content) async {
    _content = content;
  }
}
