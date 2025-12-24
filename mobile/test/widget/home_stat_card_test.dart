import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/home/home_stat_card.dart';

void main() {
  group('HomeStatCard Widget Tests', () {
    testWidgets('should display all provided data correctly',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Total Service';
      const testValue = '125';
      const testAssetPath = 'assets/icons/app_icon.png';
      const testUpdateDate = '1 day ago';
      const testPercentage = '+20%';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeStatCard(
              title: testTitle,
              value: testValue,
              assetPath: testAssetPath,
              updateDate: testUpdateDate,
              percentage: testPercentage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      expect(find.text('Update: $testUpdateDate'), findsOneWidget);
      expect(find.text(testPercentage), findsOneWidget);
    });

    testWidgets('should use default values when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeStatCard(
              title: 'Test',
              value: '100',
              assetPath: 'assets/icons/app_icon.png',
            ),
          ),
        ),
      );

      // Assert: Check default values are used
      expect(find.text('Update: 2 days ago'), findsOneWidget);
      expect(find.text('+15%'), findsOneWidget);
    });

    testWidgets('should show green arrow for positive percentage',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeStatCard(
              title: 'Revenue',
              value: 'Rp 1.000.000',
              assetPath: 'assets/icons/app_icon.png',
              percentage: '+25%',
            ),
          ),
        ),
      );

      // Assert: Find upward arrow icon (positive trend)
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('should show red arrow for negative percentage',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeStatCard(
              title: 'Revenue',
              value: 'Rp 500.000',
              assetPath: 'assets/icons/app_icon.png',
              percentage: '-10%',
            ),
          ),
        ),
      );

      // Assert: Find downward arrow icon (negative trend)
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
    });

    testWidgets('should have proper container structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeStatCard(
              title: 'Test',
              value: '50',
              assetPath: 'assets/icons/app_icon.png',
            ),
          ),
        ),
      );

      // Assert: Check widget structure
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(IntrinsicHeight), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should handle long title with ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const longTitle = 'This is a very long title that should be truncated';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: HomeStatCard(
                title: longTitle,
                value: '100',
                assetPath: 'assets/icons/app_icon.png',
              ),
            ),
          ),
        ),
      );

      // Assert: Title text should exist (may be truncated)
      expect(find.textContaining('This is'), findsOneWidget);
    });

    testWidgets('should handle long value with ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const longValue = 'Rp 999.999.999.999';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: HomeStatCard(
                title: 'Revenue',
                value: longValue,
                assetPath: 'assets/icons/app_icon.png',
              ),
            ),
          ),
        ),
      );

      // Assert: Value should be displayed
      expect(find.text(longValue), findsOneWidget);
    });

    testWidgets('should respond to different screen sizes',
        (WidgetTester tester) async {
      // Test with small screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(350, 600)),
            child: const Scaffold(
              body: HomeStatCard(
                title: 'Test',
                value: '100',
                assetPath: 'assets/icons/app_icon.png',
              ),
            ),
          ),
        ),
      );

      // Assert: Widget should render without errors
      expect(find.byType(HomeStatCard), findsOneWidget);

      // Test with larger screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: const Scaffold(
              body: HomeStatCard(
                title: 'Test',
                value: '100',
                assetPath: 'assets/icons/app_icon.png',
              ),
            ),
          ),
        ),
      );

      // Assert: Widget should still render properly
      expect(find.byType(HomeStatCard), findsOneWidget);
    });
  });
}
