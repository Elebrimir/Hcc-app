// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUserCredential implements UserCredential {
  final User? _user;

  MockUserCredential(this._user);

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;

  @override
  User? get user => _user;
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  User? _mockCurrentUser;

  @override
  User? get currentUser => _mockCurrentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email == 'invalid@example.com') {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    _mockCurrentUser = MockUser(
      uid: 'test_user_id',
      email: email,
      displayName: 'Test User',
    );
    return MockUserCredential(_mockCurrentUser);
  }

  @override
  Future<void> signOut() async {
    _mockCurrentUser = null;
  }
}

class MockUser extends Mock implements User {
  final String _uid;
  final String _email;
  final String _displayName;

  MockUser({
    required String uid,
    required String email,
    required String displayName,
  }) : _uid = uid,
       _email = email,
       _displayName = displayName;

  @override
  String get uid => _uid;

  @override
  String get email => _email;

  @override
  String get displayName => _displayName;
}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class FirebaseAuthService {
  final FirebaseAuth auth;

  FirebaseAuthService({required this.auth});

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
// A wrapper to provide a valid homePageContext for LoginPage.

void main() {
  group('FirebaseAuth Testing', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    test('should return null when currentUser is null', () async {
      // Asigna null directamente
      mockAuth._mockCurrentUser = null;
      expect(mockAuth.currentUser, isNull);
    });

    test('should return a user when currentUser is not null', () async {
      final user = MockUser(
        uid: 'test_user_id',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      // Asigna el usuario directamente
      mockAuth._mockCurrentUser = user;
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.uid, 'test_user_id');
      expect(mockAuth.currentUser!.email, 'test@example.com');
      expect(mockAuth.currentUser!.displayName, 'Test User');
    });

    test('should sign in with email and password', () async {
      final result = await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      );
      expect(result.user, isNotNull);
      expect(result.user!.uid, 'test_user_id');
      expect(result.user!.email, 'test@example.com');
      expect(result.user!.displayName, 'Test User');
    });

    test('should throw an exception when signIn fails', () async {
      expect(
        () async => await mockAuth.signInWithEmailAndPassword(
          email: 'invalid@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should sign out', () async {
      final user = MockUser(
        uid: 'test_user_id',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockAuth._mockCurrentUser = user;

      await mockAuth.signOut();

      expect(mockAuth.currentUser, isNull);
    });
  });
}
