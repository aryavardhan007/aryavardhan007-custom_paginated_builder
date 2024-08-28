import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

import 'package:flutter/material.dart';

class CustomerPaginatedBuilder extends StatefulWidget {
  const CustomerPaginatedBuilder({super.key});

  @override
  _CustomerPaginatedBuilderState createState() => _CustomerPaginatedBuilderState();
}

class _CustomerPaginatedBuilderState extends State<CustomerPaginatedBuilder> {
  final ValueNotifier<int> currentPage = ValueNotifier<int>(1);
  late Future<List<User>> futureUsers;
  final ValueNotifier<int> startPage = ValueNotifier<int>(1);
  final int visiblePages = 5;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers(currentPage.value);

    currentPage.addListener(() {
      setState(() {
        futureUsers = fetchUsers(currentPage.value);

        if (currentPage.value >= startPage.value + visiblePages) {
          startPage.value = currentPage.value - visiblePages + 1;
        } else if (currentPage.value < startPage.value) {
          startPage.value = currentPage.value;
        }
      });
    });
  }

  void _loadPage(int page) {
    currentPage.value = page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
                      return ListTile(
                        leading: Image.network(user.picture),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: startPage,
            builder: (context, start, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (start > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _loadPage(start - 1),
                    ),
                  ...List.generate(visiblePages, (index) {
                    int pageNumber = start + index;
                    return ValueListenableBuilder<int>(
                      valueListenable: currentPage,
                      builder: (context, current, child) {
                        return ElevatedButton(
                          onPressed: () => _loadPage(pageNumber),
                          child: Text(
                            '$pageNumber',
                            style: TextStyle(
                              fontWeight: current == pageNumber
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                                fontSize: current == pageNumber ? 20 : 16
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _loadPage(start + visiblePages),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    currentPage.dispose();
    startPage.dispose();
    super.dispose();
  }
}


Future<List<User>> fetchUsers(int page) async {
  final response = await http.get(
      Uri.parse('https://randomuser.me/api/?page=$page&results=10&seed=abc'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<User> users = (data['results'] as List)
        .map((user) => User.fromJson(user))
        .toList();
    return users;
  } else {
    throw Exception('Failed to load users');
  }
}
