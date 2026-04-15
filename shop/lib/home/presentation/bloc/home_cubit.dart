import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shop/common/abstract_state.dart';
import 'package:shop/news/domain/abstract_news_repository.dart';
import 'package:shop/news/domain/model/news_item.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';
import 'package:shop/product_group/domain/model/product_group.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._productGroupRepository,
    this._newsRepository,
  ) : super(const HomeState());

  final AbstractProductGroupRepository _productGroupRepository;
  final AbstractNewsRepository _newsRepository;

  Future load() async {
    try {
      final groups = await _productGroupRepository.get();
      List<NewsItem> news = const [];
      try {
        news = await _newsRepository.get();
      } catch (_) {}
      emit(HomeState(groups: groups, news: news, isLoaded: true));
    } catch (e) {
      emit(HomeState(isLoaded: true, throwable: e as Exception?));
    }
  }
}
