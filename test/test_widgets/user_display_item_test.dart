// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source codWane is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/widgets/user_display_item.dart';

void main() {
  final userCompleto = UserModel(
    name: 'Obi-Wan',
    lastname: 'Kenobi',
    email: 'obi.wan@jedi.com',
    role: 'Admin',
    image: null,
  );

  testWidgets('Muestra correctamente los datos del usuario admin', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: UserDisplayItem(user: userCompleto))),
    );
    expect(find.text('Obi-Wan Kenobi'), findsOneWidget);
    expect(find.text('Rol: Admin'), findsOneWidget);
    expect(find.text('Email: obi.wan@jedi.com'), findsOneWidget);
  });
}
