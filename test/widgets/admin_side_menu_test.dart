// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';

import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/widgets/admin_side_menu.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

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

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  testWidgets('AdminSideMenu renders and navigates to UserListPage', (
    tester,
  ) async {
    final mockObserver = MockNavigatorObserver();
    final fakeFirestore = FakeFirebaseFirestore();
    final mockUserProvider = MockUserProviderManual();

    // Add a dummy user to firestore for UserListPage
    await fakeFirestore.collection('users').add({
      'name': 'Test User',
      'lastname': 'Test Lastname',
      'email': 'test@example.com',
      'role': 'Player',
      'created_at': DateTime.now(),
    });

    // Set screen size to avoid overflow in Drawer
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: mockUserProvider,
        child: MaterialApp(
          home: Scaffold(
            drawer: AdminSideMenu(firestore: fakeFirestore),
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Text('Open Drawer'),
                  ),
                );
              },
            ),
          ),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    // Open Drawer
    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // Verify Drawer Content
    expect(find.text("Menú d'Administració"), findsOneWidget);
    expect(find.text('Usuaris'), findsOneWidget);

    // Tap on 'Usuaris'
    await tester.tap(find.text('Usuaris'));
    await tester.pumpAndSettle();

    // Verify Navigation
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(1));
    // Note: didPush is called for the initial route too.
    // We can't easily verify the exact route type without more complex setup,
    // but verifying the tap triggers a push is a good start.
    // Also, since UserListPage is pushed, we might see it in the tree if we provided its dependencies.
    // But UserListPage likely needs providers.
    // If UserListPage crashes due to missing providers, the test will fail.
    // So we should probably wrap the test in a Provider that provides necessary dependencies for UserListPage,
    // OR just verify the interaction and stop before UserListPage builds if possible (hard with pumpAndSettle).

    // Actually, UserListPage needs UserProvider.
    // So we should probably mock UserProvider if we want to fully render UserListPage.
    // Or we can just verify the drawer closes and tries to navigate.

    // Verify UserListPage content (optional, but good since we have fake data)
    expect(find.text('Llistat d\'Usuaris'), findsOneWidget);
    expect(find.text('Test User Test Lastname'), findsOneWidget);
  });
}
