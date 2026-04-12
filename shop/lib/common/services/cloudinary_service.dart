import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const _kCloudName = 'db7wmn9yi';
const _kUploadPreset = 'what_kniting_products';

class CloudinaryService {
  const CloudinaryService();

  /// Загружает изображение на Cloudinary и возвращает public_id.
  /// Бросает [CloudinaryUploadException] при ошибке.
  Future<String> uploadImage(Uint8List bytes, String filename) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_kCloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _kUploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 200) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['public_id'] as String;
    }

    throw CloudinaryUploadException(streamed.statusCode, body);
  }
}

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'CloudinaryUploadException($statusCode)';
}
