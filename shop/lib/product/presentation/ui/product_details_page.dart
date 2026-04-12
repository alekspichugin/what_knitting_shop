import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intersperse/intersperse.dart';
import 'package:shop/product/presentation/bloc/details/product_details_cubit.dart';

class ProductDetailsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();

}

class _State extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            if (state.product == null) {
              return Center(
                child: Text('Не удалось загрузить информацию о товаре!'),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 600,
                        height: 400,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        child: Image.asset(
                          'assets/graphic/${state.product!.imageAsset}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Gap(16),
                      Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Название товара, может быть длинное',
                                style: TextStyle(
                                  fontSize: 32
                                ),
                              ),
                              Gap(16),
                              Text('Очаровательный вязаный медвежонок Тедди, созданный с любовью и заботой! Эта уникальная игрушка станет лучшим другом для вашего ребенка или трогательным подарком для близкого человека.'),
                              Gap(16),
                              Text('Характеристики товара'),
                              Gap(16),
                              ElevatedButton(
                                  onPressed: () {

                                  },
                                  child: Text('Добавить в корзину')
                              )
                            ],
                          )
                      )
                    ],
                  )
                ],
              ),
            );
          }
      ),
    );
  }
}