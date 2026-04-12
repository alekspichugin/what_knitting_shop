import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/product/data/excel/product_excel_parser.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';

class ProductAdminCubit extends Cubit<ProductAdminState> {
  ProductAdminCubit(this._repo) : super(ProductAdminLoading());

  final AbstractProductRepository _repo;

  Future<void> load() async {
    emit(ProductAdminLoading());
    try {
      final products = await _repo.get();
      emit(ProductAdminLoaded(products));
    } catch (e) {
      emit(ProductAdminError(e.toString()));
    }
  }

  Future<Product> create({required String title, required String description, required List<String> imageIds}) async {
    final product = await _repo.create(title: title, description: description, imageIds: imageIds);
    await load();
    return product;
  }

  Future<void> update(Product product) async {
    await _repo.update(product);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> importProducts(List<ProductDraft> drafts) async {
    int created = 0;
    int failed = 0;

    for (var i = 0; i < drafts.length; i++) {
      emit(ProductAdminImporting(current: i + 1, total: drafts.length));
      try {
        final draft = drafts[i];
        await _repo.create(
          title: draft.title,
          description: draft.description,
          imageIds: draft.imageIds,
        );
        created++;
      } catch (_) {
        failed++;
      }
    }

    emit(ProductAdminImportDone(created: created, failed: failed));
    await load();
  }
}
