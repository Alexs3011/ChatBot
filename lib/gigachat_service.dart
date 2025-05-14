import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/io_client.dart';
import 'config.dart';

class GigaChatClient {
  final String model;
  final double temperature;
  final int maxTokens;

  GigaChatClient({
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 150,
  });

  /// Метод для получения токена доступа к GigaChat
  Future<String> _getAccessToken() async {
    final uuid = Uuid().v4();
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.post(
        Uri.parse('https://ngw.devices.sberbank.ru:9443/api/v2/oauth'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'RqUID': uuid,
          'Authorization': 'Basic $API_GIGACHAT',
        },
        body: 'scope=GIGACHAT_API_PERS',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['access_token'];
      } else {
        throw Exception('Ошибка GigaChat при получении токена: ${response.statusCode}');
      }
    } finally {
      ioClient.close();
    }
  }

  /// Метод для отправки сообщения в GigaChat и получения ответа
  Future<String> sendPrompt(String prompt) async {
    final accessToken = await _getAccessToken();
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.post(
        Uri.parse('https://gigachat.devices.sberbank.ru/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ?? 'Пустой ответ от GigaChat';
      } else {
        throw Exception('Ошибка GigaChat: ${response.statusCode}');
      }
    } finally {
      ioClient.close();
    }
  }
}