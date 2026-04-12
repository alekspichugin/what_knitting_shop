import 'package:flutter/material.dart';
import 'package:shop/product_group/domain/model/product_group.dart';

abstract class AbstractProductGroupRepository {
  Future<List<ProductGroup>> get();
  Future<ProductGroup?> getById(int id);
  Future<ProductGroup> create({required String title, required String description, required Color color, required List<int> productIds, String imageUrl = ''});
  Future<void> update(ProductGroup group);
  Future<void> delete(int id);
}
