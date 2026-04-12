import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:shop/common/abstract_state.dart';
import 'package:shop/product/data/repository/product_repository.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';

part 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {

  static const kCTag = 'ProductListCubit';

  ProductListCubit(
      this._productRepository,
      ) : super(ProductListState());

  final ProductRepository _productRepository;

  List<ViewProduct> _cachedProducts = <ViewProduct>[];

  Future load() async {
    final products = await _productRepository.get();

    _cachedProducts = products.map(_mapToViewProduct).toList();

    emit(ProductListState(
      products: _cachedProducts
    ));
  }

  ViewProduct _mapToViewProduct(Product input) {
    return ViewProduct(
        id: input.id,
        imageAsset: input.imageAsset,
        title: input.title,
        description: input.description
    );
  }
}
