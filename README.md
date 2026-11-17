# Практична робота 11 (Частина 1): Менеджер користувачів (REST API)

**Дисципліна:** Програмування для мобільних платформ  
**Варіант 1:** Менеджер користувачів (`https://jsonplaceholder.typicode.com/users`)

## Реалізований функціонал
- **GET `/users`**: Отримання та відображення списку користувачів (ім'я, email, телефон, компанія) з пошуком за ім'ям та Pull-to-refresh.
- **GET `/users/{id}`**: Детальна інформація про користувача (повна адреса та географічні координати `lat`, `lng` з переходом на карту).
- **POST `/users`**: Додавання нового користувача з валідацією формату email.
- **PUT `/users/{id}`**: Редагування даних користувача з попереднім заповненням форми.
- **DELETE `/users/{id}`**: Видалення користувача з діалогом підтвердження.
- **UI/UX**: Skeleton loading під час завантаження, обробка помилок мережі з кнопкою повторної спроби (`Retry`).

## Архітектура проєкту
```text
lib/
├── main.dart
├── models/
│   └── user.dart
├── services/
│   └── api_service.dart
├── screens/
│   ├── list_screen.dart
│   ├── detail_screen.dart
│   └── create_edit_screen.dart
└── widgets/
    ├── item_card.dart
    └── error_widget.dart
Запуск проєкту
Bash
flutter pub get
flutter run
