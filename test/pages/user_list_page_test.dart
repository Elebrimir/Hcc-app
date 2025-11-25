// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/pages/user_list_page.dart';
import 'package:hcc_app/widgets/user_display_item.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockUserProvider = MockUserProvider();
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('UserListPage Tests', () {
    testWidgets('Muestra mensaje cuando no hay usuarios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: UserListPage(firestore: fakeFirestore)),
        ),
      );

      // Wait for the stream to emit
      await tester.pumpAndSettle();

      expect(find.text('No hi ha usuaris registrats.'), findsOneWidget);
      expect(find.byType(UserDisplayItem), findsNothing);
    });

    testWidgets('Muestra la lista de usuarios cuando hay datos', (
      WidgetTester tester,
    ) async {
      // Add mock data to fake firestore
      await fakeFirestore.collection('users').add({
        'name': 'Anakin',
        'lastname': 'Skywalker',
        'email': 'anakin@jedi.com',
        'role': 'User',
      });
      await fakeFirestore.collection('users').add({
        'name': 'Obi-Wan',
        'lastname': 'Kenobi',
        'email': 'obiwan@jedi.com',
        'role': 'Admin',
      });

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
          child: MaterialApp(home: UserListPage(firestore: fakeFirestore)),
        ),
      );

      // Wait for the stream to emit and UI to rebuild
      await tester.pumpAndSettle();

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
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: UserListPage(firestore: fakeFirestore)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Llistat d\'Usuaris'), findsOneWidget);
    });
  });
}
