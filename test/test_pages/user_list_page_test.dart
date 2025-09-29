// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/widgets/user_display_item.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks.mocks.dart';

class MockUserDataWrapper extends StatelessWidget {
  final List<UserModel> mockUsers;

  const MockUserDataWrapper({
    super.key,
    required this.mockUsers,
    required this.builder,
  });

  final Widget Function(BuildContext, List<UserModel>) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, mockUsers);
  }
}

class TestableUserListPage extends StatelessWidget {
  final List<UserModel> mockUsers;

  const TestableUserListPage({super.key, required this.mockUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Llistat d\'Usuaris'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],
      body: MockUserDataWrapper(
        mockUsers: mockUsers,
        builder: (context, users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No hi ha usuaris registrats.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserDisplayItem(user: user);
            },
          );
        },
      ),
    );
  }
}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });
  group('UserListPage Tests', () {
    testWidgets('Muestra mensaje cuando no hay usuarios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestableUserListPage(mockUsers: [])),
      );

      expect(find.text('No hi ha usuaris registrats.'), findsOneWidget);
      expect(find.byType(UserDisplayItem), findsNothing);
    });

    testWidgets('Muestra la lista de usuarios cuando hay datos', (
      WidgetTester tester,
    ) async {
      final testUsers = [
        UserModel(
          name: 'Anakin',
          lastname: 'Skywalker',
          email: 'anakin@jedi.com',
          role: 'User',
          image: null,
        ),
        UserModel(
          name: 'Obi-Wan',
          lastname: 'Kenobi',
          email: 'obiwan@jedi.com',
          role: 'Admin',
          image: null,
        ),
      ];
      when(mockUserProvider.userModel).thenReturn(
        UserModel(
          name: 'Admin',
          lastname: 'Test',
          email: 'admin@hcc.com',
          role: 'Admin',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: TestableUserListPage(mockUsers: testUsers)),
        ),
      );

      expect(find.byType(UserDisplayItem), findsNWidgets(2));
      expect(find.text('Anakin Skywalker'), findsOneWidget);
      expect(find.text('Obi-Wan Kenobi'), findsOneWidget);
      expect(find.text('Email: anakin@jedi.com'), findsOneWidget);
      expect(find.text('Email: obiwan@jedi.com'), findsOneWidget);
    });

    testWidgets('Muestra el appbar con título correcto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TestableUserListPage(mockUsers: [])),
      );

      expect(find.text('Llistat d\'Usuaris'), findsOneWidget);
    });
  });
}
