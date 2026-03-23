import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class FakeUploadTask extends Fake implements UploadTask {
  final TaskSnapshot _snapshot;
  FakeUploadTask(this._snapshot);

  @override
  Future<T> then<T>(
    FutureOr<T> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) {
    return Future.value(_snapshot).then(onValue, onError: onError);
  }

  @override
  UploadTask timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) {
    return this;
  }
}

void main() {
  late UserProvider userProvider;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;

  final testUser = MockUser(
    uid: 'test_uid',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(Duration.zero);
  });

  setUp(() async {
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: testUser);
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();

    // Set up initial data in Firestore BEFORE creating the provider
    await fakeFirestore.collection('users').doc('test_uid').set({
      'email': 'test@example.com',
      'name': 'Test',
      'lastname': 'User',
      'role': 'Admin',
    });

    userProvider = UserProvider(
      auth: mockAuth,
      firestore: fakeFirestore,
      storage: mockStorage,
    );

    // Wait for the auth state listener to trigger and load data
    await Future.delayed(Duration.zero);
  });

  group('UserProvider Tests', () {
    test('Initial state should load user data if signed in', () async {
      expect(userProvider.firebaseUser, isNotNull);
      expect(userProvider.userModel, isNotNull);
      expect(userProvider.userModel!.name, 'Test');
    });

    test('signOut should clear user data', () async {
      await userProvider.signOut();
      expect(userProvider.firebaseUser, isNull);
      expect(userProvider.userModel, isNull);
    });

    test(
      'saveUserProfileDetails should update firestore and local model',
      () async {
        final success = await userProvider.saveUserProfileDetails(
          name: 'NewName',
          lastname: 'NewLastName',
        );

        expect(success, true);
        expect(userProvider.userModel!.name, 'NewName');

        final doc =
            await fakeFirestore.collection('users').doc('test_uid').get();
        expect(doc.data()!['name'], 'NewName');
      },
    );

    test(
      'uploadProfileImage should update firestore and local model',
      () async {
        final mockRef = MockReference();
        final mockSnapshot = MockTaskSnapshot();
        final fakeUploadTask = FakeUploadTask(mockSnapshot);

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockRef);
        when(() => mockRef.putFile(any())).thenAnswer((_) => fakeUploadTask);

        when(() => mockSnapshot.ref).thenReturn(mockRef);
        when(
          () => mockRef.getDownloadURL(),
        ).thenAnswer((_) async => 'https://example.com/image.png');

        final success = await userProvider.uploadProfileImage(
          File('test_path/image.png'),
        );

        expect(success, true);
        expect(userProvider.userModel!.image, 'https://example.com/image.png');

        final doc =
            await fakeFirestore.collection('users').doc('test_uid').get();
        expect(doc.data()!['image'], 'https://example.com/image.png');
      },
    );
  });
}
