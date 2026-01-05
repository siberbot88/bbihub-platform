import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/staff/performance_card.dart';
import 'package:bengkel_online_flutter/core/models/staff_performance.dart';

void main() {
  group('PerformanceCard Widget Tests', () {
    // Create test data
    final testPerformance = StaffPerformance(
      staffId: 'test-staff-id-1',
      name: 'Budi Santoso',
      role: StaffRole.seniorMechanic,
      jobsDone: 10,
      jobsInProgress: 3,
      estimatedRevenue: 5000000,
      avatarUrl: '',
    );

    testWidgets('should display staff name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('should display role', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert: Check for role display name
      expect(find.text(testPerformance.roleDisplayName), findsOneWidget);
    });

    testWidgets('should display jobs done count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should display jobs in progress count',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should display formatted revenue', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert: Should display formatted rupiah
      expect(find.text('Rp 5.000.000'), findsOneWidget);
    });

    testWidgets('should display metric labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.text('Jobs Selesai'), findsOneWidget);
      expect(find.text('Sedang Dikerjakan'), findsOneWidget);
      expect(find.text('Pendapatan: '), findsOneWidget);
    });

    testWidgets('should display CircleAvatar with person icon when no avatar',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display chevron right icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should display metric icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.build_circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(
              performance: testPerformance,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: testPerformance),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should handle zero values', (WidgetTester tester) async {
      // Arrange
      final zeroPerformance = StaffPerformance(
        staffId: 'test-staff-id-2',
        name: 'Test User',
        role: StaffRole.admin,
        jobsDone: 0,
        jobsInProgress: 0,
        estimatedRevenue: 0,
        avatarUrl: '',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: zeroPerformance),
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsNWidgets(2)); // jobsDone and jobsInProgress
      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('should display avatar image when URL is provided',
        (WidgetTester tester) async {
      // Arrange
      final performanceWithAvatar = StaffPerformance(
        staffId: 'test-staff-id-3',
        name: 'Ahmad',
        role: StaffRole.juniorMechanic,
        jobsDone: 5,
        jobsInProgress: 2,
        estimatedRevenue: 3000000,
        avatarUrl: 'https://i.pravatar.cc/150',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PerformanceCard(performance: performanceWithAvatar),
          ),
        ),
      );

      // Assert: CircleAvatar should exist
      expect(find.byType(CircleAvatar), findsOneWidget);
      // No person icon since avatar URL is provided
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
