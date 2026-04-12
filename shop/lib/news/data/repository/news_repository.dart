import 'package:flutter/material.dart';
import 'package:shop/news/domain/abstract_news_repository.dart';
import 'package:shop/news/domain/model/news_item.dart';

class NewsRepository implements AbstractNewsRepository {
  int _nextId = 4;

  final _news = <NewsItem>[
    NewsItem(
      id: 0,
      title: 'Скидка 20% на все игрушки!',
      description: 'Только до конца месяца — скидка 20% на весь раздел мягких игрушек. Успейте порадовать себя и близких!',
      date: DateTime(2026, 3, 10),
      color: Colors.redAccent,
    ),
    NewsItem(
      id: 1,
      title: 'Новая коллекция амигуруми',
      description: 'Пополнили ассортимент новыми фигурками амигуруми. Зайчики, мишки, котики — всё в наличии!',
      date: DateTime(2026, 3, 5),
      color: Colors.purple,
    ),
    NewsItem(
      id: 2,
      title: 'Весенние новинки одежды',
      description: 'Встречаем весну с новой коллекцией вязаных кардиганов и лёгких свитеров в пастельных тонах.',
      date: DateTime(2026, 2, 28),
      color: Colors.lightBlue,
    ),
    NewsItem(
      id: 3,
      title: 'Бесплатная доставка от 3000 ₽',
      description: 'При заказе на сумму от 3000 рублей доставка по всей России — бесплатно!',
      date: DateTime(2026, 2, 20),
      color: Colors.amber,
    ),
  ];

  @override
  Future<List<NewsItem>> get() async => List.unmodifiable(_news);

  @override
  Future<NewsItem> create({
    required String title,
    required String description,
    required DateTime date,
    required Color color,
  }) async {
    final item = NewsItem(id: _nextId++, title: title, description: description, date: date, color: color);
    _news.add(item);
    return item;
  }

  @override
  Future<void> update(NewsItem item) async {
    final index = _news.indexWhere((n) => n.id == item.id);
    if (index != -1) _news[index] = item;
  }

  @override
  Future<void> delete(int id) async {
    _news.removeWhere((n) => n.id == id);
  }
}
