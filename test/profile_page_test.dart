// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

// Mocks necesarios
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    // Configuración de los mocks en orden correcto (sin anidamiento)
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');

    // Configuración de Firestore
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc('test_uid')).thenReturn(mockDocRef);
    when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
  });

  testWidgets('Muestra CircularProgressIndicator inicialmente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(auth: mockAuth, firestore: mockFirestore)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Muestra error cuando no hay usuario autenticado', (
    tester,
  ) async {
    // Sobrescribir el mock para este test
    when(() => mockAuth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(auth: mockAuth, firestore: mockFirestore)),
    );

    await tester.pumpAndSettle();

    // El texto se muestra con el prefijo "Error:"
    expect(
      find.text('Error: No hi ha ninún usuari autenticat.'),
      findsOneWidget,
    );
  });

  testWidgets('Muestra datos del usuario cuando se cargan correctamente', (
    tester,
  ) async {
    when(() => mockSnapshot.exists).thenReturn(true);
    when(() => mockSnapshot.data()).thenReturn({
      'name': 'Test',
      'lastname': 'User',
      'email': 'test@example.com',
      'role': 'user',
      'image': '',
    });

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(auth: mockAuth, firestore: mockFirestore)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
  });

  testWidgets('Muestra error cuando falla la carga del perfil', (tester) async {
    // Sobrescribir el comportamiento para este test
    when(() => mockDocRef.get()).thenThrow(Exception('Error de conexión'));

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(auth: mockAuth, firestore: mockFirestore)),
    );

    await tester.pumpAndSettle();

    // El mensaje de error incluye el prefijo 'Error:' y los detalles de la excepción
    expect(
      find.textContaining('Error: Error al carregar el perfil d\'usuari'),
      findsOneWidget,
    );
  });

  testWidgets('Guarda los cambios correctamente', (tester) async {
    when(() => mockSnapshot.exists).thenReturn(true);
    when(() => mockSnapshot.data()).thenReturn({
      'name': 'Test',
      'lastname': 'User',
      'email': 'test@example.com',
      'role': 'user',
      'image': '',
    });
    when(() => mockDocRef.update(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(auth: mockAuth, firestore: mockFirestore)),
    );

    await tester.pumpAndSettle();

    // Editar los campos
    await tester.enterText(find.byType(TextFormField).at(2), 'Nuevo Nombre');
    await tester.enterText(find.byType(TextFormField).at(3), 'Nuevo Apellido');

    // Pulsar el botón de guardar
    await tester.tap(find.text('Desa canvis'));
    await tester.pump();

    // Verificar que se llamó al método update
    verify(
      () => mockDocRef.update({
        'name': 'Nuevo Nombre',
        'lastname': 'Nuevo Apellido',
      }),
    ).called(1);
  });
}
