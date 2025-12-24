import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/bottom_nav_owner.dart';

void main() {
  group('CustomBottomNavBarOwner Widget Tests', () {
    testWidgets('should display all navigation items',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: selectedIndex,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Check all labels are displayed
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('should have 4 navigation items', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Check there are 4 Expanded widgets
      expect(find.byType(Expanded), findsNWidgets(4));
    });

    testWidgets('should call onTap callback when item is tapped',
        (WidgetTester tester) async {
      // Arrange
      int tappedIndex = -1;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap on "Staff" (second item, index 1)
      await tester.tap(find.text('Staff'));
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
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {
                tappedIndices.add(index);
              },
            ),
          ),
        ),
      );

      // Tap all navigation items
      await tester.tap(find.text('Beranda'));
      await tester.pump();
      await tester.tap(find.text('Staff'));
      await tester.pump();
      await tester.tap(find.text('Laporan'));
      await tester.pump();
      await tester.tap(find.text('Profil'));
      await tester.pump();

      // Assert
      expect(tappedIndices, [0, 1, 2, 3]);
    });

    testWidgets('should highlight selected navigation item',
        (WidgetTester tester) async {
      // Act: Select first item
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: AnimatedPositioned exists for highlighting
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('should update selected index when changed',
        (WidgetTester tester) async {
      // Act: Start with index 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Update to index 2 (Laporan)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 2,
              onTap: (index) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Widget renders without errors
      expect(find.byType(CustomBottomNavBarOwner), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
    });

    testWidgets('should have SafeArea wrapper', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have InkWell for each navigation item',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: 4 InkWell widgets
      expect(find.byType(InkWell), findsNWidgets(4));
    });

    testWidgets('should animate background position when selection changes',
        (WidgetTester tester) async {
      // Act: Start with index 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Change to index 3 (Profil)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 3,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Wait for animation to start
      await tester.pump(const Duration(milliseconds: 100));

      // Assert: AnimatedPositioned for animation
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('should have LayoutBuilder for responsive sizing',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
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
              bottomNavigationBar: CustomBottomNavBarOwner(
                selectedIndex: 0,
                onTap: (index) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomBottomNavBarOwner), findsOneWidget);

      // Test with large screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: Scaffold(
              bottomNavigationBar: CustomBottomNavBarOwner(
                selectedIndex: 0,
                onTap: (index) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomBottomNavBarOwner), findsOneWidget);
    });

    testWidgets('Staff nav should have correct label',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 1,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert: Verify Staff label exists (owner-specific)
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
    });

    testWidgets('should have proper container structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBarOwner(
              selectedIndex: 0,
              onTap: (index) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });
}
