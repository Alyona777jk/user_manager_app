import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/error_widget.dart';

class DetailScreen extends StatefulWidget {
  final User initialUser;

  const DetailScreen({super.key, required this.initialUser});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() {
    setState(() {
      // Якщо ID <= 10 (існує на JSONPlaceholder), підтягуємо свіжі дані через GET /users/{id}
      if (widget.initialUser.id <= 10) {
        _userFuture = _apiService.fetchUserById(widget.initialUser.id);
      } else {
        _userFuture = Future.value(widget.initialUser);
      }
    });
  }

  Future<void> _openMap(String lat, String lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не вдалося відкрити карту')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialUser.name)),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _loadUserDetails,
            );
          }

          final user = snapshot.data ?? widget.initialUser;
          final lat = user.address.geo.lat;
          final lng = user.address.geo.lng;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Контактна інформація',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Ім\'я'),
                          subtitle: Text(user.name),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Телефон'),
                          subtitle: Text(user.phone),
                        ),
                        ListTile(
                          leading: const Icon(Icons.business),
                          title: const Text('Компанія'),
                          subtitle: Text(user.company.name),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Адреса та Геолокація',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.location_city),
                          title: const Text('Місто'),
                          subtitle: Text(user.address.city),
                        ),
                        ListTile(
                          leading: const Icon(Icons.signpost),
                          title: const Text('Вулиця'),
                          subtitle: Text(user.address.street),
                        ),
                        ListTile(
                          leading: const Icon(Icons.markunread_mailbox),
                          title: const Text('Поштовий індекс'),
                          subtitle: Text(user.address.zipcode),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.my_location, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Координати: $lat,$lng',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () => _openMap(lat, lng),
                                icon: const Icon(Icons.map),
                                label: const Text('Відкрити на карті'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
