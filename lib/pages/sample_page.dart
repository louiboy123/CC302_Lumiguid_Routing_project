import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SamplePage extends StatefulWidget {
  const SamplePage({super.key});

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  List<UserItem> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load users');
      }

      final List<dynamic> decoded = jsonDecode(response.body);

      setState(() {
        users = decoded.map((item) => UserItem.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Unable to load data: $error';
        isLoading = false;
      });
    }
  }

  void _deleteUser(int id) {
    setState(() {
      users.removeWhere((user) => user.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Students')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(errorMessage!),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Students'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(user.id.toString()),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _deleteUser(user.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserItem {
  final int id;
  final String name;
  final String email;

  UserItem({required this.id, required this.name, required this.email});

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
