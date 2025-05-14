import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Класс для работы с файлами
class FileHandler {
  /// Ассинхорнный метод получение пути к папке приложения
  /// Асинхронные операции позволяют выполнять задачи, которые могут 
  /// занять некоторое время, без блокировки основного потока выполнения программы.
  /// Т.е. программа не будет ждать завершения операции, а продолжит выполнение кода.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path; // Возвращаем путь к папке
  }

  /// Ассинхронный метод получения файла
  Future<File> _localFile(String username) async {
    final path = await _localPath;
    return File('$path/${username}_history.txt');
  }

  /// Ассинхронный метод записи сообщения в файл
  Future<File> writeMessage(String username, String message) async {
    final file = await _localFile(username);
    return file.writeAsString('$message\n', mode: FileMode.append);
  }

  /// Ассинхронный метод чтения сообщений из файла
  Future<List<String>> readMessages(String username) async {
    try {
      final file = await _localFile(username); // Получаем файл
      String contents = await file.readAsString(); // Читаем файл
      return contents.split('\n').where((line) => line.isNotEmpty).toList(); // Разделяем строки и удаляем пустые
    } catch (e) {
      return [];
    }
  }
}