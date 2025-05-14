import 'package:flutter/material.dart';
import 'package:flutter_application_1/autorisation_screen.dart';

/// Глобальное управление темой. ValueNotifier — класс, который помогает управлять значениями и уведомлять слушателей об их изменениях.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(MyApp()); // Запуск приложения
}

/// Главный класс приложения. Является точкой входа в приложение. Наследование от класса
/// StatelessWidget означает, что виджет статический и не изменяет своё состояние после создания(отображает статическую информацию)
class MyApp extends StatelessWidget {
  // Метод build предназначен для построянения интерфейса. Вызывается каждый раз автоматически, когда интерфейс заново нужно отрисовывать.
  // context - это объект, содержащиит информацию о дереве виджетов, где какой конкретно виджет находится 
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      // Слушаем изменения themeNotifier. Каждый раз, когда значение изменяется, вызывается builder
      valueListenable: themeNotifier, // Обновляем приложение при изменении темы
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Чат-бот',
          debugShowCheckedModeBanner: false, // Отключаем баннер отладки

          // Указываем светлую тему
          theme: ThemeData.light(),

          // Указываем тёмную тему
          darkTheme: ThemeData.dark(),

          // Используем значение, выбранное в themeNotifier
          themeMode: currentMode,

          home: AutorisationScreen(), // Главный экран
        );
      },
    );
  }
}

