import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/create_convocatoria_page.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:hcc_app/providers/player_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/models/player_model.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockConvocatoriaProvider extends Mock implements ConvocatoriaProvider {}

class MockPlayerProvider extends Mock implements PlayerProvider {}

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  late MockConvocatoriaProvider mockConvProvider;
  late MockPlayerProvider mockPlayerProvider;
  late MockUserProvider mockUserProvider;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockConvProvider = MockConvocatoriaProvider();
    mockPlayerProvider = MockPlayerProvider();
    mockUserProvider = MockUserProvider();
    fakeFirestore = FakeFirebaseFirestore();

    // Default behaviors
    final mockFirebaseUser = MockUser(uid: 'test_uid');
    when(() => mockConvProvider.isLoading).thenReturn(false);
    when(() => mockConvProvider.convocatorias).thenReturn([]);
    when(
      () => mockPlayerProvider.getPlayersByParent(any()),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockPlayerProvider.getPlayersByTeam(any()),
    ).thenAnswer((_) => Stream.value([]));
    when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
    when(() => mockUserProvider.userModel).thenReturn(null);
  });

  Widget createTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConvocatoriaProvider>.value(
          value: mockConvProvider,
        ),
        ChangeNotifierProvider<PlayerProvider>.value(value: mockPlayerProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
      ],
      child: MaterialApp(
        home: CreateConvocatoriaPage(firestore: fakeFirestore),
      ),
    );
  }

  group('CreateConvocatoriaPage Tests', () {
    testWidgets('should show first step (Team Selection)', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Check that the Stepper is rendered
      expect(find.byType(Stepper), findsOneWidget);
      // Check that we're on the first step (Equip)
      expect(find.text('Equip'), findsWidgets);
    });

    testWidgets('should load teams from Firestore', (tester) async {
      await fakeFirestore.collection('teams').add({
        'name': 'Team A',
        'category': 'Senior',
      });

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Team A').last, findsOneWidget);
    });

    testWidgets('should navigate steps', (tester) async {
      // Add team
      final teamRef = await fakeFirestore.collection('teams').add({
        'name': 'Team A',
        'category': 'Senior',
      });

      // Mock PlayerProvider to return players for this team
      final player = PlayerModel(
        id: 'p1',
        name: 'Player One',
        category: 'Senior',
        parentIds: [],
        teamIds: [teamRef.id],
        createdAt: Timestamp.now(),
      );
      when(
        () => mockPlayerProvider.getPlayersByTeam(teamRef.id),
      ).thenAnswer((_) => Stream.value([player]));

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Select Team
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team A').last);
      await tester.pumpAndSettle();

      // Next
      await tester.tap(find.text('Següent'));
      await tester.pumpAndSettle();

      // Step 2: Players
      expect(find.text('Jugadors'), findsWidgets);
      expect(find.text('Player One'), findsOneWidget);

      // Select Player
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      // Next
      await tester.tap(find.text('Següent'));
      await tester.pumpAndSettle();

      // Step 3: Event
      expect(find.text('Partit'), findsWidgets);
      expect(find.text('Títol del partit'), findsOneWidget);
    });
  });
}
