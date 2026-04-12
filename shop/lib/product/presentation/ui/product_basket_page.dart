import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ProductBasketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();

}

class _State extends State<ProductBasketPage> {
  static const String _botToken = '8227579614:AAG-e2hhgI7bpLCWRD164uA-W8bQzkSIalw';
  static const String _chatId = '821973633';
  final test_json_str = '{"product": {"id": "knit_toy_001", "name": "Вязаный мишка Тедди", "category": "Игрушки", "subcategory": "Медведи", "price": {"amount": 2500, "currency": "RUB", "discount": {"original_price": 3000, "discount_percentage": 17, "discount_end_date": "2024-12-31"}}, "description": "Очаровательный вязаный мишка Тедди ручной работы. Идеальный подарок для детей и взрослых. Выполнен из высококачественной пряжи с безопасными пластиковыми глазками.", "detailed_description": {"materials": ["Акриловая пряжа", "Хлопковые нитки", "Пластиковые безопасные глазки", "Синтепух"], "features": ["Ручная работа", "Гипоаллергенные материалы", "Можно стирать", "Безопасные материалы для детей"], "care_instructions": ["Стирка при 30°C", "Не отбеливать", "Сушить в расправленном виде", "Не гладить"]}, "images": [{"url": "https://example.com/images/teddy_front.jpg", "alt": "Вязаный мишка Тедди - вид спереди", "is_primary": true}, {"url": "https://example.com/images/teddy_back.jpg", "alt": "Вязаный мишки Тедди - вид сзади", "is_primary": false}, {"url": "https://example.com/images/teddy_side.jpg", "alt": "Вязаный мишка Тедди - вид сбоку", "is_primary": false}], "specifications": {"height": "25 см", "width": "15 см", "weight": "150 г", "color": "Коричневый", "color_variants": ["Коричневый", "Белый", "Серый"], "yarn_type": "Акрил премиум класса"}, "availability": {"in_stock": true, "quantity": 15, "is_ready_to_ship": true, "restock_date": null}, "shipping": {"package_size": "20×20×30 см", "package_weight": "200 г", "shipping_options": [{"type": "standard", "cost": 300, "delivery_time": "3-5 дней"}, {"type": "express", "cost": 600, "delivery_time": "1-2 дня"}]}, "craft_details": {"craftsmanship": "handmade", "maker": "Анна Петрова", "experience": "5 лет", "production_time": "3 дня", "customization_available": true, "customization_options": ["цвет", "размер", "аксессуары"]}, "reviews": {"average_rating": 4.8, "total_reviews": 47, "rating_breakdown": {"5_stars": 38, "4_stars": 7, "3_stars": 2, "2_stars": 0, "1_star": 0}, "featured_reviews": [{"user": "Марина К.", "rating": 5, "comment": "Медвежонок просто прелесть! Качество вязки отличное, дочка в восторге.", "date": "2024-01-15", "verified_purchase": true}, {"user": "Сергей И.", "rating": 5, "comment": "Заказывал в подарок. Очень качественно сделано, упаковано с душой. Получатель был в восторге!", "date": "2024-01-10", "verified_purchase": true}]}, "tags": ["мишка", "тедди", "вязаный", "ручная работа", "подарок", "для детей", "игрушка", "гипоаллергенный"], "related_products": ["knit_toy_002", "knit_toy_005", "knit_toy_008"], "seo": {"meta_title": "Вязаный мишка Тедди ручной работы - Магазин вязаных игрушек", "meta_description": "Купить вязаного мишку Тедди ручной работы. Гипоаллергенные материалы, безопасно для детей. Быстрая доставка по России.", "slug": "vyazanyj-mishka-teddi"}, "created_date": "2024-01-01", "updated_date": "2024-01-20"}}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu)
        ),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await sendMessage(test_json_str);
            },
            child: Text('Press me')
        ),
      ),
    );
  }

  static Future<void> sendMessage(String message) async {
    final url = Uri.parse(
      'https://api.telegram.org/bot$_botToken/sendMessage',
    );

    try {
      final response = await http.post(
        url,
        body: {
          'chat_id': _chatId,
          'text': message,
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}