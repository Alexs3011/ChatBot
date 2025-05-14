import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

/// Класс для получения 
class WeatherService {
  static const String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  // Метод получения погоды, передаётся название города
  static Future<String> getWeather(String city) async {
      //$_baseUrl - базовый URL (https://api.openweathermap.org/data/2.5/weather)
      // q=$city - передаём название города
      // appid=$_apiKey - передаём API-ключ
      // units=metric - указываем, что нужна температура в градусах Цельсия
      // lang=ru - запрашиваем данные на русском
      final url = Uri.parse("$baseUrl?q=$city&appid=$apiKey&units=metric&lang=ru");

      // Отправляем HTTP-запрос методом GET
      final response = await http.get(url);
      // Парсим JSON в объект
      final data = jsonDecode(response.body);

      if (data["main"] != null && data["wind"] != null) {
        // Достаём температуру и описание погоды из JSON.
        double temp = data["main"]["temp"];
        double wind = data["wind"]["speed"];
        return "Температура в $city: $temp°C\nСкорость ветра: $wind м/с";
      }

      return "Нет интернета или может ещё чего, а я так не могу. Давай чини";
    }
  }