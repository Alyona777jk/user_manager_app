import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/item_card.dart';
import 'create_edit_screen.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<User>> _usersFuture;
  List<User> _allUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _apiService.fetchUsers().then((users) {
        _allUsers = users;
        return users;
      });
    });
  }

  Future<void> _onRefresh() async {
    final freshUsers = await _apiService.fetchUsers();
    setState(() {
      _allUsers = freshUsers;
      _usersFuture = Future.value(freshUsers);
    });
  }

  Future<void> _navigateToCreate() async {
    final createdUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditScreen()),
    );

    if (createdUser != null) {
      setState(() {
        _allUsers.insert(0, createdUser);
        _usersFuture = Future.value(_allUsers);
      });
    }
  }

  Future<void> _navigateToEdit(User user) async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => CreateEditScreen(user: user)),
    );

    if (updatedUser != null) {
      setState(() {
        final index = _allUsers.indexWhere((u) => u.id == updatedUser.id);
        if (index != -1) {
          _allUsers[index] = updatedUser;
          _usersFuture = Future.value(_allUsers);
        }
      });
    }
  }

  Future<void> _confirmAndDelete(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження видалення'),
        content: Text('Ви дійсно бажаєте видалити користувача "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteUser(user.id);
        setState(() {
          _allUsers.removeWhere((u) => u.id == user.id);
          _usersFuture = Future.value(_allUsers);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Користувача "${user.name}" видалено')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер користувачів'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Пошук за ім\'ям...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonListLoader();
                }

                if (snapshot.hasError) {
                  return CustomErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: _loadUsers,
                  );
                }

                final filteredUsers = _allUsers
                    .where((u) => u.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredUsers.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Користувачів не знайдено')),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserItemCard(
                        user: user,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(initialUser: user),
                          ),
                        ),
                        onEdit: () => _navigateToEdit(user),
                        onDelete: () => _confirmAndDelete(user),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.person_add),
        label: const Text('Додати'),
      ),
    );
  }
}
