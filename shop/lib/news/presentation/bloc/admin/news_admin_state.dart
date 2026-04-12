import 'package:shop/news/domain/model/news_item.dart';

abstract class NewsAdminState {}

class NewsAdminLoading extends NewsAdminState {}

class NewsAdminLoaded extends NewsAdminState {
  NewsAdminLoaded(this.news);
  final List<NewsItem> news;
}

class NewsAdminError extends NewsAdminState {
  NewsAdminError(this.message);
  final String message;
}
