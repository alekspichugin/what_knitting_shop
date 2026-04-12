// import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ProductBasketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ProductBasketPage> {
  // TODO: реализовать страницу корзины
  // static const String _botToken = '...'; // перенести в TelegramService
  // static const String _chatId = '...';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Корзина'),
      ),
    );
  }
}
