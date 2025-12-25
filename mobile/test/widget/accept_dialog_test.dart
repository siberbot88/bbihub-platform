import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/accept_dialog.dart';

void main() {
  group('Accept Dialog Tests', () {
    testWidgets('should display dialog when showAcceptDialog is called',
        (WidgetTester tester) async {
      // Arrange
      bool confirmed = false;

      // Act: Build a scaffold with a button that shows the dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {
                    confirmed = true;
                  },
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert: Dialog should be visible and confirmed should still be false
      expect(find.byType(Dialog), findsOneWidget);
      expect(confirmed, false);
    });

    testWidgets('should display confirmation message',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(
            'Apakah anda yakin untuk menerima permintaan service ini ?'),
        findsOneWidget,
      );
    });

    testWidgets('should display green check icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert: Find check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should have Batalkan and Yakin buttons',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Batalkan'), findsOneWidget);
      expect(find.text('Yakin'), findsOneWidget);
    });

    testWidgets('should close dialog when Batalkan is tapped',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap Batalkan button
      await tester.tap(find.text('Batalkan'));
      await tester.pumpAndSettle();

      // Assert: Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should call onConfirm and close dialog when Yakin is tapped',
        (WidgetTester tester) async {
      // Arrange
      bool confirmed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {
                    confirmed = true;
                  },
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap Yakin button
      await tester.tap(find.text('Yakin'));
      await tester.pumpAndSettle();

      // Assert: Callback should be called and dialog closed
      expect(confirmed, true);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should have OutlinedButton for Batalkan',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert: Find OutlinedButton
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should have ElevatedButton for Yakin',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert: Find ElevatedButton (should have 2: one for Show, one for Yakin)
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('should have proper dialog structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAcceptDialog(
                  context,
                  onConfirm: () {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert: Check widget structure
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });
}
