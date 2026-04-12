part of 'product_details_cubit.dart';

class ProductDetailsState extends AbstractState {
  const ProductDetailsState({
    this.product,
    super.throwable,
    super.isCritical,
  });

  final ViewProduct? product;

  @override
  List get props => [
    product,
    ...super.props
  ];
}