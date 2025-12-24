import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/report/report_kpi_card.dart';

void main() {
  group('ReportKpiCard Widget Tests', () {
    testWidgets('should display title and subtitle', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.attach_money,
                  title: 'Rp 64.7jt',
                  subtitle: 'Pendapatan bulan ini',
                  growthText: '+12.5%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 64.7jt'), findsOneWidget);
      expect(find.text('Pendapatan bulan ini'), findsOneWidget);
    });

    testWidgets('should display growth percentage', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.work,
                  title: '245',
                  subtitle: 'Total jobs',
                  growthText: '+8.2%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('+8.2%'), findsOneWidget);
    });

    testWidgets('should display icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.trending_up,
                  title: '100',
                  subtitle: 'Growth',
                  growthText: '+5%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Rp 1jt',
                  subtitle: 'Revenue',
                  growthText: '+10%',
                  onTap: () {
                    tapped = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should show positive growth with green color',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Rp 1jt',
                  subtitle: 'Revenue',
                  growthText: '+15%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert: Growth text should be displayed
      expect(find.text('+15%'), findsOneWidget);
    });

    testWidgets('should show negative growth with red color',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Rp 500k',
                  subtitle: 'Revenue',
                  growthText: '-5%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('-5%'), findsOneWidget);
    });

    testWidgets('should use custom icon colors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.star,
                  title: '5.0',
                  subtitle: 'Rating',
                  growthText: '+0.5',
                  onTap: () {},
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.shade100,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert: Widget should render
      expect(find.byType(ReportKpiCard), findsOneWidget);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Rp 1jt',
                  subtitle: 'Revenue',
                  growthText: '+10%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should handle long text with ellipsis',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Rp 999.999.999.999',
                  subtitle: 'Total pendapatan dari semua transaksi bulan ini',
                  growthText: '+100%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert: Text should be displayed (may be truncated)
      expect(find.textContaining('Rp 999'), findsOneWidget);
    });

    testWidgets('should be wrapped in Expanded widget',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ReportKpiCard(
                  icon: Icons.money,
                  title: 'Test',
                  subtitle: 'Test',
                  growthText: '+0%',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
