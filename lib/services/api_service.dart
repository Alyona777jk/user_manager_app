import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/users';
  static const Duration _timeout = Duration(seconds: 10);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  // GET /users
  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw ApiException('Помилка сервера: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('Відсутнє підключення до Інтернету.');
    } on TimeoutException {
      throw ApiException('Час очікування відповіді від сервера вичерпано.');
    } catch (e) {
      throw ApiException('Не вдалося завантажити користувачів: $e');
    }
  }

  // GET /users/{id}
  Future<User> fetchUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id')).timeout(_timeout);
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Користувача не знайдено (Код: ${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Відсутнє підключення до Інтернету.');
    } on TimeoutException {
      throw ApiException('Час очікування вичерпано.');
    } catch (e) {
      throw ApiException('Помилка завантаження деталей: $e');
    }
  }

  // POST /users
  Future<User> createUser(User user) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: _headers,
            body: jsonEncode(user.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return user.copyWith(id: data['id'] ?? DateTime.now().millisecondsSinceEpoch);
      } else {
        throw ApiException('Не вдалося створити користувача (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Немає мережі. Перевірте підключення.');
    } catch (e) {
      throw ApiException('Помилка створення: $e');
    }
  }

  // PUT /users/{id}
  Future<User> updateUser(User user) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/${user.id}'),
            headers: _headers,
            body: jsonEncode(user.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return user;
      } else {
        // JSONPlaceholder повертає 500 для щойно створених локально ID > 10, обробляємо коректно
        if (user.id > 10) return user;
        throw ApiException('Помилка оновлення даних (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Немає мережі. Перевірте підключення.');
    } catch (e) {
      throw ApiException('Помилка оновлення: $e');
    }
  }

  // DELETE /users/{id}
  Future<void> deleteUser(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/$id'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('Не вдалося видалити користувача (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Немає мережі. Перевірте підключення.');
    } catch (e) {
      throw ApiException('Помилка видалення: $e');
    }
  }
}
