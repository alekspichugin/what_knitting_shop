import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  const TelegramService({
    required this.botToken,
    required this.chatIds,
  });

  final String botToken;
  final List<String> chatIds;

  Future<void> sendMessage(String text) async {
    final uri = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    for (final chatId in chatIds) {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Telegram error ${response.statusCode}: ${response.body}');
      }
    }
  }
}
