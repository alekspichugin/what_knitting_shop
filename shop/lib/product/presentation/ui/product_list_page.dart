import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intersperse/intersperse.dart';
import 'package:shop/common/cloudinary.dart';
import 'package:shop/product/presentation/bloc/list/product_list_cubit.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';
import 'package:shop/routes.dart';

class ProductListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();

}

class _State extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu)
        ),
      ),
      body: BlocBuilder<ProductListCubit, ProductListState>(
          builder: (context, state) {
            if (state.products.isEmpty) {
              return Center(
                child: Text('Не удалось загрузить список товаров!'),
              );
            }

            final productRows = state.products.slices(4);

            return ListView(
              padding: EdgeInsets.all(16),
              children: productRows.map((e) => _buildRow(context, e)).intersperse(Gap(16)).toList()
            );
          }
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<ViewProduct> products) {
    return Row(
      children: products.map((e) => _buildProductCard(context, e)).intersperse(Gap(16)).toList()
      //List.generate(4, (index) => _buildProductCard(context)).intersperse(Gap(16)).toList(),
    );
  }

  Widget _buildProductCard(BuildContext context, ViewProduct product) {
    return Expanded(
        child: InkWell(
          onTap: () => context.push('$kProductDetailsRoute/${product.id}'),
          child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: product.imageId.isNotEmpty
                            ? Image.network(
                                cloudinaryUrl(product.imageId, size: CloudinarySize.thumbnail),
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(),
                      )
                  ),
                  Gap(6),
                  Text('Название карточки товара')
                ],
              )
          ),
        )
    );
  }
}