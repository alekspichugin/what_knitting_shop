import 'package:shop/product_group/domain/model/product_group.dart';

abstract class GroupAdminState {}

class GroupAdminLoading extends GroupAdminState {}

class GroupAdminLoaded extends GroupAdminState {
  GroupAdminLoaded(this.groups);
  final List<ProductGroup> groups;
}

class GroupAdminError extends GroupAdminState {
  GroupAdminError(this.message);
  final String message;
}
