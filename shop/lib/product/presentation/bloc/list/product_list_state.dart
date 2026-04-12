part of 'product_list_cubit.dart';

class ProductListState extends AbstractState {
  const ProductListState({
    List<ViewProduct>? products,
    super.throwable,
    super.isCritical,
  }) : products = products ?? const <ViewProduct>[];

  final List<ViewProduct> products;

  @override
  List get props => [
    products,
    ...super.props
  ];
}