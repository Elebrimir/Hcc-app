import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/pages/dashboard_page.dart';
import 'package:hcc_app/providers/user_provider.dart';

// Mocks para mantener la coherencia con profile_page_test
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUserProvider extends ChangeNotifier implements UserProvider {
  final _mockUser = MockUser();

  @override
  User? get firebaseUser => _mockUser;

  @override
  UserModel? get userModel => UserModel(
    name: 'MockName',
    lastname: 'MockLastName',
    email: 'mock@example.com',
    role: 'mockRole',
  );

  @override
  Future<void> initializeUser({
    User? mockUser,
    FirebaseFirestore? mockFirestore,
  }) async {
    // No se implementa lógica adicional
  }

  @override
  Future<void> signOut() async {
    // No se implementa lógica adicional
  }
}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<UserProvider>(
        create: (_) => mockUserProvider,
        child: const DashboardPage(),
      ),
    );
  }

  testWidgets('Muestra "Inici" al cargar la página', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    expect(find.text("Inici"), findsOneWidget);
  });

  testWidgets('Navega a la segunda pestaña y muestra "Calendari"', (
    tester,
  ) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    expect(find.text("Calendari"), findsOneWidget);
  });

  // testWidgets('Navega a la tercera pestaña y muestra ProfilePage', (
  //   tester,
  // ) async {
  //   await tester.pumpWidget(createTestableWidget());
  //   await tester.tap(find.byIcon(Icons.person));
  //   await tester.pumpAndSettle();
  //   expect(find.byType(ProfilePage), findsOneWidget);
  // });
}
