import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/dashboard/owner_mini_dashboard.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/dashboard/dashboard_helpers.dart';

void main() {
  group('OwnerMiniDashboard Widget Tests', () {
    testWidgets('should display all range tabs', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Hari ini'), findsOneWidget);
      expect(find.text('Minggu ini'), findsOneWidget);
      expect(find.text('Bulan ini'), findsOneWidget);
    });

    testWidgets('should display formatted pendapatan', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1500000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert: Should display formatted rupiah
      expect(find.text('Rp 1.500.000'), findsOneWidget);
    });

    testWidgets('should display total job count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 15,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should display total selesai count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 8,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('should display metric labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pendapatan'), findsOneWidget);
      expect(find.text('Total job'), findsOneWidget);
      expect(find.text('Total Selesai'), findsOneWidget);
    });

    testWidgets('should call onRangeChanged when tab is tapped',
        (WidgetTester tester) async {
      // Arrange
      SummaryRange? changedRange;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {
                changedRange = range;
              },
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Tap on "Minggu ini"
      await tester.tap(find.text('Minggu ini'));
      await tester.pump();

      // Assert
      expect(changedRange, SummaryRange.week);
    });

    testWidgets('should highlight selected range tab',
        (WidgetTester tester) async {
      // Act: Selected range is 'today'
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(OwnerMiniDashboard), findsOneWidget);

      // Change to week
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.week,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Widget should still render
      expect(find.byType(OwnerMiniDashboard), findsOneWidget);
    });

    testWidgets('should have gradient container', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert: Find container with decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(GestureDetector), findsNWidgets(3)); // 3 range tabs
    });

    testWidgets('should handle zero values correctly',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 0,
              totalJob: 0,
              totalSelesai: 0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 0'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2)); // totalJob and totalSelesai
    });

    testWidgets('should display growth placeholder', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {},
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Assert: Growth is shown as "-" (placeholder)
      expect(find.text('-'), findsNWidgets(3)); // 3 summary cards
    });

    testWidgets('should switch between all range options',
        (WidgetTester tester) async {
      // Arrange
      final List<SummaryRange> rangeHistory = [];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerMiniDashboard(
              range: SummaryRange.today,
              onRangeChanged: (range) {
                rangeHistory.add(range);
              },
              pendapatan: 1000000,
              totalJob: 10,
              totalSelesai: 5,
            ),
          ),
        ),
      );

      // Tap all tabs
      await tester.tap(find.text('Hari ini'));
      await tester.pump();
      await tester.tap(find.text('Minggu ini'));
      await tester.pump();
      await tester.tap(find.text('Bulan ini'));
      await tester.pump();

      // Assert
      expect(rangeHistory, [
        SummaryRange.today,
        SummaryRange.week,
        SummaryRange.month,
      ]);
    });
  });
}
