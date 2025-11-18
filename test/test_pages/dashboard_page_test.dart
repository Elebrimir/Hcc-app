// ignore_for_file: subtype_of_sealed_class, prefer_const_constructors
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/pages/calendar_page.dart';
import 'package:hcc_app/pages/dashboard_page.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUser extends Mock implements User {}

class MockUserProviderManual extends ChangeNotifier implements UserProvider {
  final MockUser _mockFirebaseUser = MockUser();
  final UserModel _testUserModel;

  MockUserProviderManual()
    : _testUserModel = UserModel(
        email: 'mock@example.com',
        name: 'MockName',
        lastname: 'MockLastName',
        role: 'Admin',
        image: '',
        createdAt: Timestamp.now(),
      ) {
    when(() => _mockFirebaseUser.uid).thenReturn('test_uid_manual');
    when(() => _mockFirebaseUser.email).thenReturn('mock@example.com');
  }

  @override
  User? get firebaseUser => _mockFirebaseUser;

  @override
  UserModel? get userModel => _testUserModel;

  @override
  bool get isUploadingImage => false;

  @override
  bool get isSavingProfile => false;

  @override
  Future<bool> uploadProfileImage(File imageFile) async => true;
  @override
  Future<bool> saveUserProfileDetails({
    required String name,
    required String lastname,
  }) async => true;
  @override
  Future<void> initializeUser({
    User? mockUser,
    FirebaseFirestore? mockFirestore,
  }) async {}
  @override
  Future<void> signOut() async {}
}

class MockEventProvider extends ChangeNotifier implements EventProvider {
  final List<Event> _mockedEvents;

  MockEventProvider(this._mockedEvents);
  @override
  bool get isLoading => false;

  @override
  List<Event> get events => _mockedEvents;

  @override
  Future<String> addEvent(
    Map<String, dynamic> eventData,
    String creatorUid,
  ) async {
    return 'mock_event_id';
  }

  @override
  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {}
}

void main() {
  late MockUserProviderManual mockUserProvider;
  late MockEventProvider mockEventProvider;

  final now = DateTime.now();
  final mockEvents = [
    Event(
      id: '1',
      title: "Entrenamiento Mañana",
      description: "Fuerza",
      startTime: DateTime.utc(now.year, now.month, 15, 10, 0),
      endTime: DateTime.utc(now.year, now.month, 15, 11, 0),
      confirmedUsers: [],
      location: "Gimnasio",
    ),
    Event(
      id: '2',
      title: "Partido Amistoso",
      description: "Contra B",
      startTime: DateTime.utc(now.year, now.month, 15, 18, 0),
      endTime: DateTime.utc(now.year, now.month, 15, 20, 0),
      confirmedUsers: [],
      location: "Estadio Central",
    ),
    Event(
      id: '3',
      title: "Reunión Equipo",
      description: "Planificación",
      startTime: DateTime.utc(now.year, now.month, 15, 21, 0),
      endTime: DateTime.utc(now.year, now.month, 15, 22, 0),
      confirmedUsers: [],
      location: "Sala de Juntas",
    ),
  ];

  setUpAll(() {
    registerFallbackValue(File('dummy_path_for_fallback'));
  });

  setUp(() {
    resetMocktailState();
    mockUserProvider = MockUserProviderManual();
    mockEventProvider = MockEventProvider(mockEvents);
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ChangeNotifierProvider<EventProvider>.value(value: mockEventProvider),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  // --- Tests ---

  testWidgets('Muestra "Inici" inicialmente', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    expect(find.text("Inici"), findsOneWidget);
  });

  testWidgets('Navega a la segunda pestaña y muestra "Calendari"', (
    tester,
  ) async {
    await tester.pumpWidget(createTestableWidget());

    final calendarIconFinder = find.byIcon(Icons.calendar_today);
    expect(calendarIconFinder, findsOneWidget);
    await tester.tap(calendarIconFinder);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPage), findsOneWidget);
    expect(find.text("Inici"), findsNothing);
  });

  testWidgets('El calendario muestra y filtra eventos al seleccionar un día', (
    tester,
  ) async {
    await tester.pumpWidget(createTestableWidget());

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('Entrenamiento Mañana'), findsOneWidget);

    await tester.tap(find.text('18'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
  });

  testWidgets('Navega a la tercera pestaña y muestra ProfilePage', (
    tester,
  ) async {
    await tester.pumpWidget(createTestableWidget());

    final profileIconFinder = find.byIcon(Icons.person);
    expect(profileIconFinder, findsOneWidget);
    await tester.tap(profileIconFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text("Inici"), findsNothing);
    expect(find.text("Calendari"), findsNothing);
  });
}
