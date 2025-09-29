// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source codWane is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/widgets/user_display_item.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  final userCompleto = UserModel(
    name: 'Obi-Wan',
    lastname: 'Kenobi',
    email: 'obi.wan@jedi.com',
    role: 'Admin',
    image: null,
  );

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  testWidgets('Muestra correctamente los datos del usuario admin', (
    WidgetTester tester,
  ) async {
    when(mockUserProvider.userModel).thenReturn(
      UserModel(
        name: 'Admin',
        lastname: 'Test',
        email: 'admin@test.com',
        role: 'Admin',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: mockUserProvider,
        child: MaterialApp(
          home: Scaffold(body: UserDisplayItem(user: userCompleto)),
        ),
      ),
    );
    expect(find.text('Obi-Wan Kenobi'), findsOneWidget);
    expect(find.text('Rol: Admin'), findsOneWidget);
    expect(find.text('Email: obi.wan@jedi.com'), findsOneWidget);
  });
}
