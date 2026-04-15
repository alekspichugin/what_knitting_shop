part of 'product_group_cubit.dart';

class ProductGroupState extends AbstractState {
  const ProductGroupState({
    this.groupId,
    this.groupTitle,
    List<ViewProduct>? products,
    this.isLoaded = false,
    super.throwable,
    super.isCritical,
  }) : products = products ?? const <ViewProduct>[];

  final int? groupId;
  final String? groupTitle;
  final List<ViewProduct> products;
  final bool isLoaded;

  @override
  List get props => [groupId, groupTitle, products, isLoaded, ...super.props];
}
