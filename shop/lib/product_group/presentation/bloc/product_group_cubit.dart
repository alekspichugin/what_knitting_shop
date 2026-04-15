import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shop/common/abstract_state.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';

part 'product_group_state.dart';

class ProductGroupCubit extends Cubit<ProductGroupState> {
  ProductGroupCubit(
    this._productGroupRepository,
    this._productRepository,
    this._groupId,
  ) : super(const ProductGroupState());

  final AbstractProductGroupRepository _productGroupRepository;
  final AbstractProductRepository _productRepository;
  final int _groupId;

  Future load() async {
    final group = await _productGroupRepository.getById(_groupId);
    if (group == null) {
      emit(const ProductGroupState(isLoaded: true));
      return;
    }

    final products = group.productIds.isEmpty
        ? <Product>[]
        : await _productRepository.get(ids: group.productIds);

    emit(ProductGroupState(
      groupId: _groupId,
      groupTitle: group.title,
      products: products.map(_mapToViewProduct).toList(),
      isLoaded: true,
    ));
  }

  ViewProduct _mapToViewProduct(Product input) {
    return ViewProduct(
      id: input.id,
      imageIds: input.imageIds,
      title: input.title,
      description: input.description,
      price: input.price,
    );
  }
}
