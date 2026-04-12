import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/news/domain/abstract_news_repository.dart';
import 'package:shop/news/domain/model/news_item.dart';
import 'package:shop/news/presentation/bloc/admin/news_admin_state.dart';

class NewsAdminCubit extends Cubit<NewsAdminState> {
  NewsAdminCubit(this._repo) : super(NewsAdminLoading());

  final AbstractNewsRepository _repo;

  Future<void> load() async {
    emit(NewsAdminLoading());
    try {
      final news = await _repo.get();
      emit(NewsAdminLoaded(news));
    } catch (e) {
      emit(NewsAdminError(e.toString()));
    }
  }

  Future<void> create({required String title, required String description, required DateTime date, required Color color}) async {
    await _repo.create(title: title, description: description, date: date, color: color);
    await load();
  }

  Future<void> update(NewsItem item) async {
    await _repo.update(item);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
