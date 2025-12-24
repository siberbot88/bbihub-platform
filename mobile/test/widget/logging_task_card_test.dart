import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/service_logging/logging_task_card.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

void main() {
  group('LoggingTaskCard Widget Tests', () {
    // Create test service data
    final testService = ServiceModel(
      id: '1',
      code: 'SRV-001',
      name: 'Ganti Oli',
      description: 'Ganti oli mesin',
      status: 'pending',
      scheduledDate: DateTime(2024, 12, 25, 10, 30),
    );

    testWidgets('should display service name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.text('Ganti Oli'), findsOneWidget);
    });

    testWidgets('should display status', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.text('pending'), findsOneWidget);
    });

    testWidgets('should display formatted date and time',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert: Should display formatted date
      expect(find.textContaining('25 Des'), findsOneWidget);
      expect(find.textContaining('10:30'), findsOneWidget);
    });

    testWidgets('should display customer name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert: Display customer name from service
      expect(find.text(testService.displayCustomerName), findsOneWidget);
    });

    testWidgets('should display service ID', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.text('ID: 1'), findsOneWidget);
    });

    testWidgets('should show "Tetapkan Mekanik" button for pending status',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.text('Tetapkan Mekanik'), findsOneWidget);
    });

    testWidgets('should show "Lihat Detail" button for in_progress status',
        (WidgetTester tester) async {
      // Arrange
      final inProgressService = ServiceModel(
        id: '2',
        code: 'SRV-002',
        name: 'Service Rutin',
        status: 'in_progress',
        scheduledDate: DateTime(2024, 12, 26),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: inProgressService),
          ),
        ),
      );

      // Assert
      expect(find.text('Lihat Detail'), findsOneWidget);
    });

    testWidgets('should show "Buat Invoice" button for completed status',
        (WidgetTester tester) async {
      // Arrange
      final completedService = ServiceModel(
        id: '3',
        code: 'SRV-003',
        name: 'Tune Up',
        status: 'completed',
        scheduledDate: DateTime(2024, 12, 24),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: completedService),
          ),
        ),
      );

      // Assert
      expect(find.text('Buat Invoice'), findsOneWidget);
    });

    testWidgets('should display vehicle info', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert: Check vehicle display
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should have CircleAvatar for customer photo',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should handle on_process status variant',
        (WidgetTester tester) async {
      // Arrange
      final onProcessService = ServiceModel(
        id: '4',
        code: 'SRV-004',
        name: 'Ganti Ban',
        status: 'on_process',
        scheduledDate: DateTime(2024, 12, 27),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: onProcessService),
          ),
        ),
      );

      // Assert: Should show "Lihat Detail" for on_process
      expect(find.text('Lihat Detail'), findsOneWidget);
    });

    testWidgets('should display description if available',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoggingTaskCard(service: testService),
          ),
        ),
      );

      // Assert: Description should be displayed
      expect(find.text('Ganti oli mesin'), findsOneWidget);
    });
  });
}
