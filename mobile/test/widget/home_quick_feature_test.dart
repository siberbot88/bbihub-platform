import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/home/home_quick_feature.dart';

void main() {
  group('HomeQuickFeature Widget Tests', () {
    testWidgets('should display label text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Service',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Service'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Dashboard',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.byType(HomeQuickFeature));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should have GestureDetector for interactions',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Profile',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should have ScaleTransition for animation',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Settings',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('should use default icon size when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Test',
            ),
          ),
        ),
      );

      // Assert: Widget should render with default size
      expect(find.byType(HomeQuickFeature), findsOneWidget);
    });

    testWidgets('should use custom icon size when provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Test',
              iconSize: 32,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(HomeQuickFeature), findsOneWidget);
    });

    testWidgets('should adapt to different screen sizes',
        (WidgetTester tester) async {
      // Test with small screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(350, 600)),
            child: const Scaffold(
              body: HomeQuickFeature(
                assetPath: 'assets/icons/app_icon.png',
                label: 'Test',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HomeQuickFeature), findsOneWidget);

      // Test with large screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(650, 1000)),
            child: const Scaffold(
              body: HomeQuickFeature(
                assetPath: 'assets/icons/app_icon.png',
                label: 'Test',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HomeQuickFeature), findsOneWidget);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Test',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should handle null onTap gracefully',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'Test',
              onTap: null,
            ),
          ),
        ),
      );

      // Tap should not throw error
      await tester.tap(find.byType(HomeQuickFeature));
      await tester.pumpAndSettle();

      // Assert: No error
      expect(find.byType(HomeQuickFeature), findsOneWidget);
    });

    testWidgets('should display multi-word labels correctly',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeQuickFeature(
              assetPath: 'assets/icons/app_icon.png',
              label: 'View Dashboard',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('View Dashboard'), findsOneWidget);
    });
  });
}
