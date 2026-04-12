import 'package:flutter/material.dart';
import 'package:shop/news/domain/model/news_item.dart';

abstract class AbstractNewsRepository {
  Future<List<NewsItem>> get();
  Future<NewsItem> create({required String title, required String description, required DateTime date, required Color color});
  Future<void> update(NewsItem item);
  Future<void> delete(int id);
}
