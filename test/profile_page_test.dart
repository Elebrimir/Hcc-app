// ignore_for_file: subtype_of_sealed_class, prefer_const_constructors
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockUser extends Mock implements User {}

class MockUserProvider extends Mock
    with ChangeNotifier
    implements UserProvider {}

void main() {
  late MockUserProvider mockUserProvider;
  late MockUser mockFirebaseUser;
  late UserModel testUserModel;

  setUpAll(() {
    registerFallbackValue(File('dummy_path_for_fallback'));
  });

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockFirebaseUser = MockUser();
    when(() => mockFirebaseUser.uid).thenReturn('test_uid');
    when(() => mockFirebaseUser.email).thenReturn('test@example.com');

    testUserModel = UserModel(
      email: 'test@example.com',
      name: 'Test',
      lastname: 'User',
      role: 'tester',
      image: 'https://via.placeholder.com/150',
      createdAt: Timestamp.now(),
    );

    when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
    when(() => mockUserProvider.userModel).thenReturn(testUserModel);
    when(() => mockUserProvider.isUploadingImage).thenReturn(false);
    when(() => mockUserProvider.isSavingProfile).thenReturn(false);

    when(
      () => mockUserProvider.uploadProfileImage(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockUserProvider.saveUserProfileDetails(
        name: any(named: 'name'),
        lastname: any(named: 'lastname'),
      ),
    ).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: MaterialApp(home: Scaffold(body: ProfilePage())),
    );
  }

  testWidgets(
    'Muestra CircularProgressIndicator inicialmente si userModel es null',
    (tester) async {
      when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
      when(() => mockUserProvider.userModel).thenReturn(null);
      when(() => mockUserProvider.isUploadingImage).thenReturn(false);
      when(() => mockUserProvider.isSavingProfile).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    },
  );

  testWidgets('Muestra mensaje para iniciar sesión si firebaseUser es null', (
    tester,
  ) async {
    when(() => mockUserProvider.firebaseUser).thenReturn(null);
    when(() => mockUserProvider.userModel).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Si us plau, inicia sessió.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets(
    'Muestra CircularProgressIndicator si userModel es null pero hay usuario (estado inicial)',
    (tester) async {
      when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
      when(() => mockUserProvider.userModel).thenReturn(null);
      when(() => mockUserProvider.isUploadingImage).thenReturn(false);
      when(() => mockUserProvider.isSavingProfile).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No s\'han pogut carregar les dades.'), findsNothing);
      expect(find.byType(ListView), findsNothing);
    },
  );

  testWidgets(
    'Muestra los datos del usuario cuando userModel está disponible',
    (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(TextFormField, 'test@example.com'),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextFormField, 'tester'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Test'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'User'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      });
    },
  );

  testWidgets(
    'Llama a userProvider.saveUserProfileDetails al pulsar "Desa canvis"',
    (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockUserProvider.saveUserProfileDetails(
            name: 'Nuevo Nombre',
            lastname: 'Nuevo Apellido',
          ),
        ).thenAnswer((_) async => true);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final nameFieldFinder = find.byType(TextFormField).at(2);
        final lastnameFieldFinder = find.byType(TextFormField).at(3);
        final saveButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Desa canvis',
        );

        expect(nameFieldFinder, findsOneWidget);
        expect(lastnameFieldFinder, findsOneWidget);
        expect(saveButtonFinder, findsOneWidget);

        await tester.enterText(nameFieldFinder, 'Nuevo Nombre');
        await tester.enterText(lastnameFieldFinder, 'Nuevo Apellido');
        await tester.pump();

        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        verify(
          () => mockUserProvider.saveUserProfileDetails(
            name: 'Nuevo Nombre',
            lastname: 'Nuevo Apellido',
          ),
        ).called(1);
        expect(find.text('Perfil desat correctament!'), findsOneWidget);
      });
    },
  );
}
