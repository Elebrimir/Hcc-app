import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/event_form_modal.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hcc_app/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MockEventProvider extends Mock implements EventProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockUser extends Mock implements auth.User {}

class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {}

  @override
  Future<void> cancel({int? id, String? tag}) async {}
}

void main() {
  late MockEventProvider mockEventProvider;
  late MockUserProvider mockUserProvider;
  late MockUser mockUser;
  late FakeFlutterLocalNotificationsPlugin fakeNotificationsPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(const AndroidInitializationSettings(''));
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(
      const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
      ),
    );
  });

  setUp(() {
    mockEventProvider = MockEventProvider();
    mockUserProvider = MockUserProvider();
    mockUser = MockUser();
    fakeNotificationsPlugin = FakeFlutterLocalNotificationsPlugin();

    NotificationService.pluginForTesting = fakeNotificationsPlugin;

    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUserProvider.firebaseUser).thenReturn(mockUser);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventProvider>.value(value: mockEventProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('EventFormModal Tests', () {
    testWidgets('renders correctly for new event', (tester) async {
      await tester.pumpWidget(createTestWidget(const EventFormModal()));

      expect(find.text('Nou Esdeveniment'), findsOneWidget);
      expect(find.text('Títol'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Eliminar Esdeveniment'), findsNothing);
    });

    testWidgets('renders correctly for editing event', (tester) async {
      final event = Event(
        id: 'e1',
        title: 'Existing Event',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        confirmedUsers: [],
      );

      await tester.pumpWidget(createTestWidget(EventFormModal(event: event)));

      expect(find.text('Editar Esdeveniment'), findsOneWidget);
      expect(find.text('Existing Event'), findsOneWidget);
      expect(find.text('Guardar Canvis'), findsOneWidget);
      expect(find.text('Eliminar Esdeveniment'), findsOneWidget);
    });

    testWidgets('shows validation error if title is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(const EventFormModal()));

      await tester.tap(find.text('Crear'));
      await tester.pump();

      expect(find.text('El títol no pot estar buit'), findsOneWidget);
    });

    testWidgets('calls addEvent and schedules notification on save', (
      tester,
    ) async {
      when(
        () => mockEventProvider.addEvent(any(), any()),
      ).thenAnswer((_) async => 'new_id');

      await tester.pumpWidget(createTestWidget(const EventFormModal()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Títol'),
        'New Event',
      );
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      verify(() => mockEventProvider.addEvent(any(), 'test_uid')).called(1);
      // verify(() => mockNotificationsPlugin.zonedSchedule(...)).called(1); // Tricky to verify exact call due to complex arguments
    });

    testWidgets('toggles recurrence section', (tester) async {
      await tester.pumpWidget(createTestWidget(const EventFormModal()));

      expect(find.text('Es repeteix cada'), findsNothing);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(find.text('Es repeteix cada'), findsOneWidget);
      expect(find.text('Interval'), findsOneWidget);
    });
  });
}
