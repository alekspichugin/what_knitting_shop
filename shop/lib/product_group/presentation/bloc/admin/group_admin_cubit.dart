import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';
import 'package:shop/product_group/domain/model/product_group.dart';
import 'package:shop/product_group/presentation/bloc/admin/group_admin_state.dart';

class GroupAdminCubit extends Cubit<GroupAdminState> {
  GroupAdminCubit(this._repo) : super(GroupAdminLoading());

  final AbstractProductGroupRepository _repo;

  Future<void> load() async {
    emit(GroupAdminLoading());
    try {
      final groups = await _repo.get();
      emit(GroupAdminLoaded(groups));
    } catch (e) {
      emit(GroupAdminError(e.toString()));
    }
  }

  Future<void> create({required String title, required String description, required Color color, required List<int> productIds, String imageUrl = ''}) async {
    await _repo.create(title: title, description: description, color: color, productIds: productIds, imageUrl: imageUrl);
    await load();
  }

  Future<void> update(ProductGroup group) async {
    await _repo.update(group);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
