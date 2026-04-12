part of 'product_group_cubit.dart';

class ProductGroupState extends AbstractState {
  const ProductGroupState({
    this.groupId,
    this.groupTitle,
    List<ViewProduct>? products,
    super.throwable,
    super.isCritical,
  }) : products = products ?? const <ViewProduct>[];

  final int? groupId;
  final String? groupTitle;
  final List<ViewProduct> products;

  @override
  List get props => [groupId, groupTitle, products, ...super.props];
}
