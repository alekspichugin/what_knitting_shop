part of 'home_cubit.dart';

class HomeState extends AbstractState {
  const HomeState({
    List<ProductGroup>? groups,
    List<NewsItem>? news,
    this.isLoaded = false,
    super.throwable,
    super.isCritical,
  })  : groups = groups ?? const <ProductGroup>[],
        news = news ?? const <NewsItem>[];

  final List<ProductGroup> groups;
  final List<NewsItem> news;
  final bool isLoaded;

  @override
  List get props => [groups, news, isLoaded, ...super.props];
}
