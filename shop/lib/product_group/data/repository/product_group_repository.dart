import 'package:flutter/material.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';
import 'package:shop/product_group/domain/model/product_group.dart';

class ProductGroupRepository implements AbstractProductGroupRepository {
  int _nextId = 6;

  final _groups = <int, ProductGroup>{
    0: ProductGroup(
      id: 0,
      title: 'Мягкие игрушки',
      description: 'Вязаные мягкие игрушки для детей и взрослых',
      color: Colors.orange,
      productIds: List.generate(8, (i) => i),
    ),
    1: ProductGroup(
      id: 1,
      title: 'Аксессуары',
      description: 'Шапки, шарфы, варежки и другие аксессуары',
      color: Colors.teal,
      productIds: List.generate(6, (i) => i + 8),
    ),
    2: ProductGroup(
      id: 2,
      title: 'Одежда',
      description: 'Свитера, кардиганы, жилеты и другая вязаная одежда',
      color: Colors.indigo,
      productIds: List.generate(7, (i) => i + 14),
    ),
    3: ProductGroup(
      id: 3,
      title: 'Пледы и покрывала',
      description: 'Тёплые вязаные пледы и покрывала для дома',
      color: Colors.brown,
      productIds: List.generate(5, (i) => i + 21),
    ),
    4: ProductGroup(
      id: 4,
      title: 'Амигуруми',
      description: 'Маленькие вязаные фигурки в японском стиле',
      color: Colors.pink,
      productIds: List.generate(8, (i) => i + 26),
    ),
    5: ProductGroup(
      id: 5,
      title: 'Новогодние',
      description: 'Вязаные игрушки и украшения к Новому году',
      color: Colors.green,
      productIds: List.generate(6, (i) => i + 34),
    ),
  };

  @override
  Future<List<ProductGroup>> get() async => _groups.values.toList();

  @override
  Future<ProductGroup?> getById(int id) async => _groups[id];

  @override
  Future<ProductGroup> create({
    required String title,
    required String description,
    required Color color,
    required List<int> productIds,
    String imageUrl = '',
  }) async {
    final group = ProductGroup(id: _nextId, title: title, description: description, color: color, productIds: productIds, imageUrl: imageUrl);
    _groups[_nextId++] = group;
    return group;
  }

  @override
  Future<void> update(ProductGroup group) async {
    _groups[group.id] = group;
  }

  @override
  Future<void> delete(int id) async {
    _groups.remove(id);
  }
}
