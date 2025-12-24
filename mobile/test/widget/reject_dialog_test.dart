import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/reject_dialog.dart';

void main() {
  group('Reject Dialog Tests', () {
    testWidgets('should display dialog when showRejectDialog is called',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('should display title "Tolak Pesanan Servis"',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
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
      expect(find.text('Tolak Pesanan Servis'), findsOneWidget);
    });

    testWidgets('should display reason dropdown',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
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
      expect(find.text('Alasan Penolakan'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should display notes text field', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
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
      expect(find.text('Additional Notes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have Batalkan and Lanjutkan buttons',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
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
      expect(find.text('Lanjutkan'), findsOneWidget);
    });

    testWidgets('should close dialog when Batalkan is tapped',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap Batalkan
      await tester.tap(find.text('Batalkan'));
      await tester.pumpAndSettle();

      // Assert: Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should allow entering text in notes field',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Enter text in TextField
      await tester.enterText(
        find.byType(TextField),
        'Service tidak tersedia',
      );

      // Assert
      expect(find.text('Service tidak tersedia'), findsOneWidget);
    });

    testWidgets('should use StatefulBuilder for dialog state',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Assert: StatefulBuilder should exist
      expect(find.byType(StatefulBuilder), findsOneWidget);
    });

    testWidgets('should have proper dialog structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
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
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('Confirm Reject Dialog Tests', () {
    testWidgets('should show confirmation dialog after Lanjutkan is tapped',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap Lanjutkan
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Assert: Confirmation dialog should appear
      expect(
        find.text('Apakah anda yakin untuk menolak permintaan service ini ?'),
        findsOneWidget,
      );
    });

    testWidgets('should display red close icon in confirmation dialog',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Assert: Find close_rounded icon
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets(
        'should have Batalkan and Yakin buttons in confirmation dialog',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await  tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Batalkan'), findsOneWidget);
      expect(find.text('Yakin'), findsOneWidget);
    });

    testWidgets('should call onConfirm with reason and description',
        (WidgetTester tester) async {
      // Arrange
      String? capturedReason;
      String? capturedDescription;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRejectDialog(
                  context,
                  onConfirm: (reason, desc) {
                    capturedReason = reason;
                    capturedDescription = desc;
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

      // Enter notes
      await tester.enterText(find.byType(TextField), 'Test description');

      // Tap Lanjutkan
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Tap Yakin in confirmation dialog
      await tester.tap(find.text('Yakin'));
      await tester.pumpAndSettle();

      // Assert
      expect(capturedReason, isNotNull);
      expect(capturedDescription, 'Test description');
    });
  });
}
