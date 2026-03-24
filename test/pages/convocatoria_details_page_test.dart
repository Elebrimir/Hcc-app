import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/convocatoria_details_page.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:hcc_app/providers/player_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

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
    when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
    when(() => mockUserProvider.userModel).thenReturn(null);
  });

  testWidgets('ConvocatoriaDetailsPage displays convocatoria info correctly', (
    WidgetTester tester,
  ) async {
    final now = Timestamp.now();
    final convocatoria = ConvocatoriaModel(
      id: 'conv_1',
      teamId: 'team_1',
      teamName: 'Senior A',
      eventId: 'event_1',
      players: [
        ConvokedUser(
          userId: 'u1',
          name: 'Player 1',
          role: 'player',
          status: ConvocationStatus.confirmed,
        ),
        ConvokedUser(
          userId: 'u2',
          name: 'Player 2',
          role: 'player',
          status: ConvocationStatus.pending,
        ),
        ConvokedUser(
          userId: 'u3',
          name: 'Player 3',
          role: 'player',
          status: ConvocationStatus.declined,
        ),
      ],
      delegates: [
        ConvokedUser(
          userId: 'd1',
          name: 'Delegate 1',
          role: 'delegate',
          status: ConvocationStatus.confirmed,
        ),
      ],
      createdAt: now,
    );

    // Pre-populate Firestore
    await fakeFirestore
        .collection('convocatorias')
        .doc(convocatoria.id)
        .set(convocatoria.toFirestore());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConvocatoriaProvider>.value(
            value: mockConvProvider,
          ),
          ChangeNotifierProvider<PlayerProvider>.value(
            value: mockPlayerProvider,
          ),
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
        child: MaterialApp(
          home: ConvocatoriaDetailsPage(
            convocatoria: convocatoria,
            firestore: fakeFirestore,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check header
    expect(find.text('Senior A'), findsOneWidget);

    // Check sections
    expect(find.text('Jugadors (3)'), findsOneWidget);
    expect(find.text('Delegats (1)'), findsOneWidget);

    // Check users
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
    expect(find.text('Delegate 1'), findsOneWidget);

    // Check statuses
    expect(find.text('CONFIRMED'), findsNWidgets(2));
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('DECLINED'), findsOneWidget);
  });

  testWidgets('ConvocatoriaDetailsPage handles empty lists gracefully', (
    WidgetTester tester,
  ) async {
    final now = Timestamp.now();
    final convocatoria = ConvocatoriaModel(
      id: 'conv_2',
      teamId: 'team_2',
      teamName: 'Junior B',
      eventId: 'event_2',
      players: [],
      delegates: [],
      createdAt: now,
    );

    // Pre-populate Firestore
    await fakeFirestore
        .collection('convocatorias')
        .doc(convocatoria.id)
        .set(convocatoria.toFirestore());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConvocatoriaProvider>.value(
            value: mockConvProvider,
          ),
          ChangeNotifierProvider<PlayerProvider>.value(
            value: mockPlayerProvider,
          ),
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
        child: MaterialApp(
          home: ConvocatoriaDetailsPage(
            convocatoria: convocatoria,
            firestore: fakeFirestore,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Jugadors (0)'), findsOneWidget);
    expect(find.text('Delegats (0)'), findsOneWidget);
    expect(find.text('No hi ha ningú assignat.'), findsNWidgets(2));
  });
}
