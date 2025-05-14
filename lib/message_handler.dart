import 'weather.dart';  // Подключаем класс с погодой

/// Класс для обработки сообщений
class Answer {
  List<Map<String, String>> messages = []; // Двумерный массив для сообщений, содержит кто отправил сообщение и само сообщение
  // Map для хранения регулярных выражений и ответов на них
  final Map<RegExp, String Function()> _responses = {
    RegExp(r'привет', caseSensitive: false): () => 'Привет! Как я могу помочь?',
    RegExp(r'который\s*час', caseSensitive: false): () => 'Сейчас ${DateTime.now().hour}:${DateTime.now().minute}.',
  };

  
  /// Метож для удаления лишних символов и приведения к нижнему регистру
  /// RegExp(r'[^\w\sа-яА-ЯёЁ]') — регулярное выражение, которое ищет все символы, кроме:
  // \w — букв и цифр латиницы (A-Z, a-z, 0-9, _);
  // \s — пробелов, табуляции и перевода строки;
  // а-яА-ЯёЁ — всех русских букв, включая букву ё.
  // replaceAll(...) — заменяет найденные символы (которые не соответствуют правилам) на пустую строку '', то есть удаляет их.
  String preprocess(String message) {
    return message.replaceAll(RegExp(r'[^\w\sа-яА-ЯёЁ]'), '').trim().toLowerCase();
  }

  /// Метод для обработки математических выражений
  String _handleMathExpression(String message) {
    final mathRegExp = RegExp(r'(\d+)\s*([\+\-\*/])\s*(\d+)', caseSensitive: false);
    final match = mathRegExp.firstMatch(message);
    if (match != null) {
      final num1 = int.parse(match.group(1)!);
      final operator = match.group(2)!;
      final num2 = int.parse(match.group(3)!);
      switch (operator) {
        case '+':
          return '${num1 + num2}';
        case '-':
          return '${num1 - num2}';
        case '*':
          return '${num1 * num2}';
        case '/':
          if (num2 == 0) return 'Деление на ноль невозможно';
          return (num1 / num2).toStringAsFixed(3);
        default:
          return 'Неизвестная операция';
      }
    }
    return 'Не смог вычислить(';
  }

  // Метод для обработки команды умножения
  String _handleMulCommand(String message) {
    final mulRegExp = RegExp(r'умножь\s+(\d+)\s+на\s+(\d+)', caseSensitive: false);
    final match = mulRegExp.firstMatch(message);// firstMatch - ищет первое совпадение с регулярным выражением
    if (match != null) {
      final num1 = int.parse(match.group(1)!);
      final num2 = int.parse(match.group(2)!);
      final result = num1 * num2;
      return '$result';
    }
    return 'Не смог вычислить(';
  }

  // Метод для обработки команды сложения
  String _handleAddCommand(String message) {
    final addRegExp = RegExp(r'сложи\s+(\d+)\s+и\s+(\d+)', caseSensitive: false);
    final match = addRegExp.firstMatch(message);// firstMatch - ищет первое совпадение с регулярным выражением
    if (match != null) {
      final num1 = int.parse(match.group(1)!); 
      final num2 = int.parse(match.group(2)!);
      final result = num1 + num2;
      return '$result';
    }
    return 'Не смог вычислить(';
  }

  // Метод для обработки команды деления
  String _handleDivCommand(String message) {
    final divRegExp = RegExp(r'раздели\s+(\d+)\s+на\s+(\d+)', caseSensitive: false);
    final match = divRegExp.firstMatch(message);// firstMatch - ищет первое совпадение с регулярным выражением
    if (match != null) {
      final num1 = int.parse(match.group(1)!);
      final num2 = int.parse(match.group(2)!);
      final result = (num1 / num2).toStringAsFixed(3);
      return '$result';
    }
    return 'Не смог вычислить(';
  }

  // Метод для обработки команды вычитания 
  String _handleSubCommand(String message) {
    final subRegExp = RegExp(r'вычти\s+(\d+)\s+из\s+(\d+)', caseSensitive: false);
    final match = subRegExp.firstMatch(message);// firstMatch - ищет первое совпадение с регулярным выражением
    if (match != null) {
      final num1 = int.parse(match.group(1)!);
      final num2 = int.parse(match.group(2)!);
      final result = num1 - num2;
      return '$result';
    }
    return 'Не смог вычислить(';
  }

  Future<String> _generateWeather(String message) async {
    if (message.toLowerCase().startsWith('погода в ')) {
      String city = message.substring(9).trim();  // Извлекаем название города
      return await WeatherService.getWeather(city);
    }
    return 'Нет интернета или может ещё чего, а я так не могу. Давай чини';
  }

  // Для каждой записи мы проверяем соответствие регулярному выражению
  // и возвращаем соответствующий ответ
  Future<String> generateResponse (String message) async {
    message = preprocess(message);

    // Проверка на погоду
    if (message.toLowerCase().startsWith('погода в ')){
       return await _generateWeather(message);
    }
    
    // Проверка на команду с умножением
    if (message.toLowerCase().startsWith('умножь')){
       return _handleMulCommand(message);
    }
    
    // Проверка на команду с умножением
    if (message.toLowerCase().startsWith('сложи')) {
      return _handleAddCommand(message);
    }

    // Проверка на команду с умножением
    if (message.toLowerCase().startsWith('раздели')) {
      return _handleDivCommand(message);
    }

    // Проверка на команду с умножением
    if (message.toLowerCase().startsWith('вычти')) {
      return _handleSubCommand(message);
    }

    // Проверка на математическое выражение
    final mathRegExp = RegExp(r'(\d+)\s*([\+\-\*/])\s*(\d+)', caseSensitive: false);
    if (mathRegExp.hasMatch(message)) {
      return _handleMathExpression(message);
    }

    for (var entry in _responses.entries) {
      if (entry.key.hasMatch(message)) {
        return entry.value();
      }
    }
    return 'Извините, я не понимаю ваш запрос.';
  }
}