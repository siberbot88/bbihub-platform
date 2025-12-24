import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/bottom_nav.dart';

void main() {
  group('CustomBottomNavBarAdmin Widget Tests', () {
    testWidgets('should display all navigation items',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: selectedIndex,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Check all labels are displayed
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Servis'), findsOneWidget);
      expect(find.text('Dasbor'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('should have 4 navigation items', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Check there are 4 Expanded widgets (one for each nav item)
      expect(find.byType(Expanded), findsNWidgets(4));
    });

    testWidgets('should highlight selected navigation item',
        (WidgetTester tester) async {
      // Act: Select first item (Beranda)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Animated background should exist
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('should call onTap callback when item is tapped',
        (WidgetTester tester) async {
      // Arrange
      int tappedIndex = -1;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap on "Servis" (second item, index 1)
      await tester.tap(find.text('Servis'));
      await tester.pump();

      // Assert
      expect(tappedIndex, 1);
    });

    testWidgets('should call onTap with correct index for each item',
        (WidgetTester tester) async {
      // Arrange
      final List<int> tappedIndices = [];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {
                tappedIndices.add(index);
              },
            ),
          ),
        ),
      );

      // Tap each navigation item
      await tester.tap(find.text('Beranda'));
      await tester.pump();
      await tester.tap(find.text('Servis'));
      await tester.pump();
      await tester.tap(find.text('Dasbor'));
      await tester.pump();
      await tester.tap(find.text('Profil'));
      await tester.pump();

      // Assert: Should have tapped indices 0, 1, 2, 3
      expect(tappedIndices, [0, 1, 2, 3]);
    });

    testWidgets('should update selected index when changed',
        (WidgetTester tester) async {
      // Act: Start with index 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Update to index 2
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 2,
              onTap: (index) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Widget should render without errors
      expect(find.byType(CustomBottomNavBarAdmin), findsOneWidget);
    });

    testWidgets('should have SafeArea wrapper', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have Container with proper decoration',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Find the main container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomNavBarAdmin),
          matching: find.byType(Container),
        ).first,
      );

      // Assert: Container should have BoxDecoration
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('should have InkWell for each navigation item',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Should have 4 InkWell widgets (one for each nav item)
      expect(find.byType(InkWell), findsNWidgets(4));
    });

    testWidgets('should animate background position when selection changes',
        (WidgetTester tester) async {
      // Act: Start with index 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Change to index 3
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 3,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Wait for animation to start
      await tester.pump(const Duration(milliseconds: 100));

      // Assert: AnimatedPositioned should exist
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('should have LayoutBuilder for responsive sizing',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    testWidgets('should render on different screen sizes',
        (WidgetTester tester) async {
      // Test with small screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(360, 640)),
            child: Scaffold(
              bottomNavigationBar: CustomBottomNavBarAdmin(
                selectedIndex: 0,
                onTap: (index) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomBottomNavBarAdmin), findsOneWidget);

      // Test with large screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: Scaffold(
              bottomNavigationBar: CustomBottomNavBarAdmin(
                selectedIndex: 0,
                onTap: (index) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomBottomNavBarAdmin), findsOneWidget);
    });

    testWidgets('should handle rapid tap events', (WidgetTester tester) async {
      // Arrange
      final List<int> tapSequence = [];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarAdmin(
              selectedIndex: 0,
              onTap: (index) {
                tapSequence.add(index);
              },
            ),
          ),
        ),
      );

      // Rapid taps
      await tester.tap(find.text('Beranda'));
      await tester.tap(find.text('Servis'));
      await tester.tap(find.text('Dasbor'));
      await tester.pump();

      // Assert: All taps should be registered
      expect(tapSequence.length, 3);
      expect(tapSequence, [0, 1, 2]);
    });
  });
}
