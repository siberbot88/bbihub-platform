import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/service_logging/logging_summary_boxes.dart';

void main() {
  group('LoggingSummaryBoxes Widget Tests', () {
    testWidgets('should display correct counts for all statuses',
        (WidgetTester tester) async {
      // Arrange: Setup test data
      const int pendingCount = 5;
      const int inProgressCount = 3;
      const int completedCount = 10;

      // Act: Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: pendingCount,
              inProgress: inProgressCount,
              completed: completedCount,
            ),
          ),
        ),
      );

      // Assert: Verify the counts are displayed correctly
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should display correct labels for all statuses',
        (WidgetTester tester) async {
      // Act: Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: 1,
              inProgress: 1,
              completed: 1,
            ),
          ),
        ),
      );

      // Assert: Verify all labels are displayed
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('should render three boxes', (WidgetTester tester) async {
      // Act: Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: 0,
              inProgress: 0,
              completed: 0,
            ),
          ),
        ),
      );

      // Assert: Verify there are 3 Expanded widgets (one for each box)
      expect(find.byType(Expanded), findsNWidgets(3));
    });

    testWidgets('should handle zero counts correctly',
        (WidgetTester tester) async {
      // Act: Build the widget with all zeros
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: 0,
              inProgress: 0,
              completed: 0,
            ),
          ),
        ),
      );

      // Assert: Verify zeros are displayed
      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('should handle large counts correctly',
        (WidgetTester tester) async {
      // Arrange
      const int largeCount = 999;

      // Act: Build the widget with large numbers
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: largeCount,
              inProgress: largeCount,
              completed: largeCount,
            ),
          ),
        ),
      );

      // Assert: Verify large numbers are displayed
      expect(find.text('999'), findsNWidgets(3));
    });

    testWidgets('should have correct structure with Row and Padding',
        (WidgetTester tester) async {
      // Act: Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: 1,
              inProgress: 2,
              completed: 3,
            ),
          ),
        ),
      );

      // Assert: Verify widget structure
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display all boxes in a single Row',
        (WidgetTester tester) async {
      // Act: Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggingSummaryBoxes(
              pending: 5,
              inProgress: 3,
              completed: 7,
            ),
          ),
        ),
      );

      // Assert: Get the Row widget
      final rowWidget = tester.widget<Row>(find.byType(Row));
      
      // Verify Row has 3 children (three Expanded widgets)
      expect(rowWidget.children.length, 3);
    });
  });
}
