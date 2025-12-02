import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/pages/create_convocatoria_page.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:provider/provider.dart';

class MockConvocatoriaProvider extends ChangeNotifier
    implements ConvocatoriaProvider {
  @override
  Future<void> createConvocatoria({
    required String teamId,
    required String teamName,
    required event,
    required List<ConvokedUser> players,
    required List<ConvokedUser> delegates,
  }) async {}

  @override
  bool get isLoading => false;

  @override
  List<ConvocatoriaModel> get convocatorias => [];

  @override
  Future<void> fetchConvocatorias() async {}

  @override
  Future<void> updateConvocationStatus(
    String convocatoriaId,
    String userId,
    ConvocationStatus newStatus,
  ) async {}
}

void main() {
  late MockConvocatoriaProvider mockProvider;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockProvider = MockConvocatoriaProvider();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<ConvocatoriaProvider>.value(
        value: mockProvider,
        child: CreateConvocatoriaPage(firestore: fakeFirestore),
      ),
    );
  }

  group('CreateConvocatoriaPage Tests', () {
    testWidgets('should show first step (Team Selection)', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Check that the Stepper is rendered
      expect(find.byType(Stepper), findsOneWidget);
      // Check that we're on the first step (Team selection)
      expect(find.text('Equip'), findsOneWidget);
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
      // Add team with players
      await fakeFirestore.collection('teams').add({
        'name': 'Team A',
        'players': [
          {'email': 'p1@test.com', 'name': 'Player', 'lastname': 'One'},
        ],
      });

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
      expect(find.text('Partit'), findsOneWidget);
      expect(find.text('Títol del partit'), findsOneWidget);
    });
  });
}
