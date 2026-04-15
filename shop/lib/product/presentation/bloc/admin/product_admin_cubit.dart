import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/product/data/excel/product_excel_parser.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/admin/product_admin_state.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';

class ProductAdminCubit extends Cubit<ProductAdminState> {
  ProductAdminCubit(this._repo, this._groupRepo) : super(ProductAdminLoading());

  final AbstractProductRepository _repo;
  final AbstractProductGroupRepository _groupRepo;

  Future<void> load() async {
    emit(ProductAdminLoading());
    try {
      final products = await _repo.get();
      emit(ProductAdminLoaded(products));
    } catch (e) {
      emit(ProductAdminError(e.toString()));
    }
  }

  Future<Product> create({required String title, required String description, required List<String> imageIds, double price = 0}) async {
    final product = await _repo.create(title: title, description: description, imageIds: imageIds, price: price);
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

  /// Создаёт или обновляет товар и синхронизирует его привязку к группе.
  Future<void> saveWithGroup({
    required Product? original,
    required String title,
    required String description,
    required List<String> imageIds,
    required int? selectedGroupId,
    double price = 0,
  }) async {
    final groups = await _groupRepo.get();

    if (original == null) {
      // Создание
      final product = await _repo.create(title: title, description: description, imageIds: imageIds, price: price);
      if (selectedGroupId != null) {
        final group = groups.firstWhereOrNull((g) => g.id == selectedGroupId);
        if (group != null && !group.productIds.contains(product.id)) {
          await _groupRepo.update(group.copyWith(productIds: [...group.productIds, product.id]));
        }
      }
    } else {
      // Обновление
      await _repo.update(original.copyWith(title: title, description: description, imageIds: imageIds, price: price));

      final oldGroup = groups.firstWhereOrNull((g) => g.productIds.contains(original.id));
      if (oldGroup?.id != selectedGroupId) {
        if (oldGroup != null) {
          await _groupRepo.update(oldGroup.copyWith(
            productIds: oldGroup.productIds.where((id) => id != original.id).toList(),
          ));
        }
        if (selectedGroupId != null) {
          final newGroup = groups.firstWhereOrNull((g) => g.id == selectedGroupId);
          if (newGroup != null && !newGroup.productIds.contains(original.id)) {
            await _groupRepo.update(newGroup.copyWith(productIds: [...newGroup.productIds, original.id]));
          }
        }
      }
    }

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
          price: draft.price,
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
