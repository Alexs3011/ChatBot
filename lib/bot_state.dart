import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'message_handler.dart';
import 'file_handler.dart';
import 'gigachat_service.dart';

// MVC (Model-View-Controller) — это архитектурный паттерн, который делит модули на три группы:
// Модель. Содержит данные приложения, за которыми приходит пользователь.
// Представление. Показывает эти данные в понятном для пользователя виде.
// Контроллер. Принимает пользовательские команды и преобразует данные по этим командам. 

/// Класс, отвечающий за логику загрузки и отправки сообщений
class BotLogic {
  final Answer _messageHandler; // Объект для обработки сообщений 
  final FileHandler _fileHandler; // Объект для работы с файлами

  // Конструктор инициализирует объекты
  BotLogic({
    required Answer messageHandler,
    required FileHandler fileHandler,
  })  : _messageHandler = messageHandler,
        _fileHandler = fileHandler;

  // Загрузка сообщений из файла ассинхронно
  Future<List<Map<String, String>>> loadMessages(String username) async {
    List<String> savedMessages = await _fileHandler.readMessages(username); // Читаем сообщения из файла
    // Здесь мы формируем и возвращаем список Map
    return savedMessages.map((msg) {
      return {
        'sender': msg.startsWith('user:') ? 'user' : 'bot', 
        'text': msg.substring(5) // Убираем первые 5 символов "user:" или "bot:"
      };
    }).toList();
  }

  /// Приватный метод для отправки сообщений
  Future<List<Map<String, String>>> sendMessage({
    required String username,
    required String userInput,
    required List<Map<String, String>> currentMessages,
    required bool useGigaChat,
    required GigaChatClient gigaChat,
  }) async {
    if (userInput.isNotEmpty) { // Проверка есть ли в сообщении что-то
      String userMessage = userInput.trim(); // Получаем сообщение пользователя
      String botResponse = ''; // Переменная для ответа бота
      if (useGigaChat) {
        botResponse = await gigaChat.sendPrompt(userMessage);      }
      else{
        botResponse = await _messageHandler.generateResponse(userMessage); // Получаем ответ бота
      }
      // Формируем новый список на базе старого
      final updatedMessages = List<Map<String, String>>.from(currentMessages);
      updatedMessages.add({'sender': 'user', 'text': userMessage}); // Добавляем как сообщение от пользователя
      updatedMessages.add({'sender': 'bot', 'text': botResponse}); // Добавляем ответ бота

      // Записываем новые сообщения в файл
      await _fileHandler.writeMessage(username, 'user: $userMessage'); // Записываем сообщение пользователя
      await _fileHandler.writeMessage(username, 'bot: $botResponse'); // Записываем ответ бота

      return updatedMessages;
    }
    // Если текст пустой, просто возвращаем текущие сообщения без изменений
    return currentMessages;
  }
}


/// Класс bot, в котором отрисовывается весь интерфейс самого бота. 
/// StatefulWidget для отрисовки сообщений динамически 
class Bot extends StatefulWidget {
  final String username; // Имя пользователя
  Bot({required this.username}); // Конструктор класса Bot

  // Переопределение метода createState._BotState - конструктор состояния
  @override
  _BotState createState() => _BotState();
}

/// Приватный класс, который отвечает за внутреннее состояние виджета
/// extends State<Bot> означает, что _BotState наследуется от State<Bot>, 
/// что даёт ему возможность изменять интерфейс через setState()
/// Отвечает за интерфейс бота
class _BotState extends State<Bot> {
  final TextEditingController _controller = TextEditingController(); // Объект для отслеживания состояния сообщениия. TextEditingController предназначен для управления ввода текста в виджет TextField.
  final FocusNode _focusNode = FocusNode(); // Управляемый фокус
  final Answer _messageHandler = Answer(); // Объект для обработки сообщений 
  final FileHandler _fileHandler = FileHandler(); // Объект для работы с файлами
  late BotLogic _logic; // Экземпляр класса, который содержит методы загрузки/отправки
  final ScrollController _scrollController = ScrollController();  // Объявляем контроллер прокрутки
  bool useGigaChat = false;
  final gigaChat = GigaChatClient(
    model: 'GigaChat',
    temperature: 0.9,
    maxTokens: 200,
  );

  // Вызывается при создании виджета. Используется для инициализации состояния
  @override
  void initState() {
    super.initState();
    _logic = BotLogic(
      messageHandler: _messageHandler,
      fileHandler: _fileHandler,
    );
    _loadMessages(); // Загрузка при инициализации
  }

  // Вызов метода загрузки сообщений из BotLogic
  Future<void> _loadMessages() async {
    final loaded = await _logic.loadMessages(widget.username);
    setState(() {
      _messageHandler.messages = loaded;
    });
  }
  
  // Вызов метода отправки сообщений из BotLogic
  Future<void> _sendMessage() async {
    final updated = await _logic.sendMessage(
      username: widget.username,
      userInput: _controller.text,
      currentMessages: _messageHandler.messages,
      useGigaChat: useGigaChat,
      gigaChat: gigaChat,
    );
    setState(() {
      _messageHandler.messages = updated;
      _controller.clear(); // Очищаем поле ввода
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(); // Прокручиваем после отрисовки
    });
  }

  /// Метод отправки сообщений по нажатию Enter
  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      _sendMessage(); // Отправка сообщения при нажатии Enter
    }
  }

  /// Очистка ресурсов при удалении виджета. Вызвывается при удалении виджета автоматически
  @override
  void dispose() {
    _focusNode.dispose(); // Освобождаем фокус
    _controller.dispose(); // Освобождаем контроллер
    super.dispose(); // Освобождаем родительский класс
  }

  // Метод для прокрутки вниз
  void _scrollToBottom() {
    // Проверка, если контроллер не null
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // Прокручиваем до конца списка
        duration: Duration(milliseconds: 300), // Время анимации прокрутки
        curve: Curves.easeOut, // Плавная анимация
      );
    }
  }

@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Определяем активна ли тёмная тема

  // Основной контейнер с градиентом фона
  return Scaffold(
    extendBodyBehindAppBar: true, // Расширяем тело за пределы AppBar
    appBar: AppBar(
  title: Text('Чат c ${widget.username}'),
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  actions: [
    Row(
      children: [
        Text("GigaChat", style: TextStyle(color: Colors.white)),
        Switch(
          value: useGigaChat,
          onChanged: (value) {
            setState(() {
              useGigaChat = value;
            });
          },
        ),
      ],
    ),
  ],
),

    body: Container(
      decoration: BoxDecoration(
        // Фоновый градиент под цвет авторизации
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade900, Colors.black]
              : [Colors.lightBlue.shade100, Colors.blue.shade300],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: SafeArea( 
        child: Column( // Виджет, который располагает дочерние элементы вертикально
          children: [ // Список виджетов, которые нужно расположить вертикально

            // Отрисовка самих сообщений. Expanded - для расположения сообщений
            Expanded(
              child: ListView.builder( // Создание динамически списка сообщений. Для отображения сообщений
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                itemCount: _messageHandler.messages.length, // Сколько элементов в списке. Для того, чтобы понять сколько сообщений отображать
                itemBuilder: (context, index) { // Функция, возвращает виджет Align для отображения каждого сообщения. 
                  final message = _messageHandler.messages[index]; // Берем сообщение по текущему индексу 
                  final isUser = message['sender'] == 'user'; // Определяем кто отправитель

                  return AnimatedContainer( // Анимация при появлении сообщения
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, // Выравнивание по стороне
                    child: Container( // Контейнер вокруг сообщения. Для стилизации
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // Ограничиваем ширину
                      margin: EdgeInsets.symmetric(vertical: 6), // Отступы между сообщениями
                      padding: EdgeInsets.all(14), // Внутренний отступ
                      decoration: BoxDecoration( // Стилизация контейнера
                        color: isUser ? Colors.tealAccent.shade100 : Colors.white.withOpacity(0.8), // Цвет пузыря
                        borderRadius: BorderRadius.only( // Скругление углов
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        boxShadow: [ // Тень под сообщением
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Text( // Текст сообщения
                        message['text'] ?? '', // Используем ?? на случай, если ключ отсутствует
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Реализация строки сообщения. Padding - отступ от экрана вокруг дочернего виджета
            Padding(
              padding: const EdgeInsets.all(12.0), // Отступ от краёв
              child: RawKeyboardListener( // Отслеживание клавиатуры
                focusNode: _focusNode, // Создаем новый FocusNode для отслеживания фокуса
                onKey: _handleKeyPress, // Обработка нажатий клавиш
                child: Container(
                  decoration: BoxDecoration( // Оформление поля ввода
                    color: isDark ? Colors.grey[850] : Colors.white, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [ // Тень поля ввода
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Отступы внутри поля
                  child: Row( // Все виджеты горизонтально
                    children: [
                      Expanded(
                        child: TextField( // Поле ввода текста
                          controller: _controller,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Введите сообщение...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Иконка отправки сообщения
                      IconButton(
                        icon: Icon(Icons.send_rounded),
                        color: isDark ? Colors.tealAccent : Colors.blueAccent,
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}