import 'message_handler.dart';
import 'package:test/test.dart';


void main() {
  late Answer messageHandler;

  setUp(() {
    messageHandler = Answer();
  });

  group('Preprocess', () {
    test('удаляет спецсимволы и приводит к нижнему регистру', () {
      final input = 'ПрИвЕт!!! Как ДЕЛА??';
      final expected = 'привет как дела';
      expect(messageHandler.preprocess(input), equals(expected));
    });

    test('обрезает пробелы по краям', () {
      final input = '   Тестовое СОБЩЕНИЕ   ';
      expect(messageHandler.preprocess(input), equals('тестовое сообщение'));
    });
  });

  // Async и await используются, потому что generateResponse - асинхронный метод из-за _generateWeather
  group('Static responses', () {
    test('ответ на "привет"', () async {
      final response = await messageHandler.generateResponse('Привет');
      expect(response.toLowerCase(), contains('привет'));  
    });

    test('ответ на "который час" содержит время в формате H:M', () async {
      final response = await messageHandler.generateResponse('Который час?');
      // Ожидаем формат вроде 'Сейчас 14:5'
      expect(RegExp(r"\d{1,2}:\d{1,2}").hasMatch(response), isTrue);
    });
  });

  group('Math expressions', () {
    test('сложение через символ', () async {
      expect(await messageHandler.generateResponse('3 + 5'), equals('8'));
    });

    test('вычитание через символ', () async {
      expect(await messageHandler.generateResponse('10 - 7'), equals('3'));
    });

    test('умножение через символ', () async {
      expect(await messageHandler.generateResponse('6 * 7'), equals('42'));
    });

    test('деление через символ', () async {
      expect(await messageHandler.generateResponse('8 / 2'), equals('4.000'));
    });

    test('деление на ноль', () async {
      expect(await messageHandler.generateResponse('8 / 0'), equals('Деление на ноль невозможно'));
    });

    test('неизвестная операция возвращает ошибку', () async {
      expect(await messageHandler.generateResponse('8 ^ 2'), equals('Не смог вычислить('));
    });
  });

  group('Command handling', () {
    test('умножь командой', () async {
      expect(await messageHandler.generateResponse('Умножь 3 на 4'), equals('12'));
    });

    test('сложи командой', () async {
      expect(await messageHandler.generateResponse('Сложи 5 и 9'), equals('14'));
    });

    test('раздели командой', () async {
      expect(await messageHandler.generateResponse('Раздели 8 на 2'), equals('4.000'));
    });

    test('вычти командой', () async {
      expect(await messageHandler.generateResponse('Вычти 3 из 10'), equals('7'));
    });
  });

  group('Unknown input', () {
    test('непонимаемое сообщение', () async {
      final response = await messageHandler.generateResponse('Расскажи анекдот');
      expect(response, equals('Извините, я не понимаю ваш запрос.'));
    });
  });
}
