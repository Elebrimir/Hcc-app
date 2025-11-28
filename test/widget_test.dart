import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/main.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUserProvider extends Mock implements UserProvider {}

class MockEventProvider extends Mock implements EventProvider {}

class MockUser extends Mock implements User {}

void main() {
  late MockUserProvider mockUserProvider;
  late MockEventProvider mockEventProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockEventProvider = MockEventProvider();
  });

  testWidgets('Smoke test - App starts and shows login options', (
    WidgetTester tester,
  ) async {
    when(() => mockUserProvider.firebaseUser).thenReturn(null);
    when(() => mockUserProvider.addListener(any())).thenReturn(null);
    when(() => mockUserProvider.removeListener(any())).thenReturn(null);
    when(() => mockEventProvider.addListener(any())).thenReturn(null);
    when(() => mockEventProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ChangeNotifierProvider<EventProvider>.value(value: mockEventProvider),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acceso'), findsOneWidget);
    expect(find.text('Registro'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
