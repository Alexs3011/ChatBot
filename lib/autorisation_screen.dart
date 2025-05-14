import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'bot_state.dart';

/// Класс первого окна, наследуется от класса StatelessWidget
class AutorisationScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController(); // Контроллер поля ввода

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // Определяем активна ли темная тема. 

    // Возвращаем виджет Scaffold, выступает контейнером для организации решений дизайна интерфейса, 
    // таких как панель приложения, панель навигации, нижняя панель навигации и основная область контента.
    return Scaffold(
      extendBodyBehindAppBar: true, 

      // Заголовок окна appbar - панель инструментов в верхней части экрана, которая обычно 
      // содержит название приложения, кнопки навигации и другие иконки действий. 
      appBar: AppBar(
        title: Text('Авторизация'),
        backgroundColor: Colors.transparent,
        elevation: 1,
        centerTitle: true,
        // Наша кнопочка для переключения темы
        actions: [
          // Следим за состоянием переключателя темы
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier, // Храним состояние переключателя темы
            // Строим виджет в зависимости от состояния переключателя темы
            builder: (context, mode, _) { // mode - текущее состояние переключателя темы, 
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark 
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                ),
                onPressed: () { // Функция, вызываемая при нажатии на кнопку
                  themeNotifier.value =
                      mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
        ],
      ),


      // Реализация основной структуры окна. body используется для показа основного содержимого экрана
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: double.infinity,
        height: double.infinity, 
        decoration: BoxDecoration( 
          // Фоновый градиент, плавный переход между двумя темами
          gradient: LinearGradient(
            colors: isDark 
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.lightBlue.shade200, Colors.blue.shade400],
            begin: Alignment.topCenter, // Переход сверху
            end: Alignment.bottomCenter, // Вниз
          ),
        ),

          // Виджет для отступов дочерних виджетов
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60), // Внешний отступ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // Картинка для экрана
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/4712/4712035.png',
                  height: 150,
                ),

                SizedBox(height: 40), // Отступ

                // Анимированное появление блока
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  padding: EdgeInsets.all(20), 
                  decoration: BoxDecoration( 
                    color: isDark ? Colors.grey[850] : Colors.white, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [ 
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5), // Сдвиг тени
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Виджет для плавного перехода между 2 окнами
                      Hero(
                        tag: 'Screen 1',
                        child: Container(
                          width: 300,
                          height: 60,
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              hintText: "Введи своё имя",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: "Привет, давай знакомиться =)",
                              prefixIcon: Icon(Icons.person_outline), // Иконка внутри поля
                              filled: true,
                              fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25), // Отступ

                      ElevatedButton( // Кнопка
                        // Функция, вызываемая при нажатии.
                        onPressed: () {
                          // Запуск перехода
                          // Т.к. мы вызваем Navigator.of(context) текущий экран перемещается в стек, и новый экран отображается поверх
                          // Автоматически добавляет кнопку "назад" в AppBar
                          Navigator.of(context).push(
                            // Красивый переход сдвигом. Создание нового экрана
                            // Параметры: pageBuilder - строит новый экран, transitionsBuilder - анимация перехода
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return Bot(username: _nameController.text.trim());
                              },
                              // Описание анимации. 
                              // secondaryAnimation - вторичная анимация, child - дочерний виджет
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // Начальная позиция
                                const end = Offset.zero; // Конечная позиция в центре экрана
                                var tween = Tween(begin: begin, end: end); // Анимация от begin до end
                                var offsetAnimation = animation.drive(tween); // Запуск перехода
                                // Виджет анимации сдвига
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );  
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Размер кнопки
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Скругление углов
                          ),
                          backgroundColor: isDark ? Colors.tealAccent[700] : Colors.blueAccent, // Цвет кнопки
                          elevation: 6, // Тень кнопки
                        ),
                        // Текст кнопки
                        child: Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.black : Colors.white, // Цвет текста зависит от темы
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}