import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/work/work_card.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/work/work_helpers.dart';

void main() {
  group('WorkCard Widget Tests', () {
    // Create test data
    final testWorkItem = WorkItem(
      id: '1',
      workOrder: 'WO-001',
      customer: 'John Doe',
      vehicle: 'Honda Beat',
      plate: 'B 1234 XYZ',
      service: 'Ganti Oli + Tune Up',
      schedule: DateTime(2024, 12, 21, 10, 30),
      mechanic: 'Budi Santoso',
      price: 150000,
      status: WorkStatus.pending,
    );

    testWidgets('should display work order number', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('WO-001'), findsOneWidget);
    });

    testWidgets('should display customer name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should display vehicle and plate number',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('Honda Beat'), findsOneWidget);
      expect(find.text('B 1234 XYZ'), findsOneWidget);
    });

    testWidgets('should display service description', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('Ganti Oli + Tune Up'), findsOneWidget);
    });

    testWidgets('should display mechanic name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('should display formatted price', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 150.000'), findsOneWidget);
    });

    testWidgets('should display "Rp -" when price is null',
        (WidgetTester tester) async {
      // Arrange
      final noPriceWork = WorkItem(
        id: '2',
        workOrder: 'WO-002',
        customer: 'Jane Doe',
        vehicle: 'Yamaha Mio',
        plate: 'B 5678 ABC',
        service: 'Servis Rutin',
        schedule: DateTime(2024, 12, 22),
        mechanic: 'Ahmad',
        price: null,
        status: WorkStatus.process,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: noPriceWork),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp -'), findsOneWidget);
    });

    testWidgets('should show PENDING status badge', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('should show PROCESS status badge', (WidgetTester tester) async {
      // Arrange
      final processWork = WorkItem(
        id: '3',
        workOrder: 'WO-003',
        customer: 'Alice',
        vehicle: 'Suzuki Nex',
        plate: 'D 9999 ZZZ',
        service: 'Ganti Ban',
        schedule: DateTime(2024, 12, 23),
        mechanic: 'Rudi',
        price: 200000,
        status: WorkStatus.process,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: processWork),
          ),
        ),
      );

      // Assert
      expect(find.text('PROCESS'), findsOneWidget);
    });

    testWidgets('should show SELESAI status badge', (WidgetTester tester) async {
      // Arrange
      final doneWork = WorkItem(
        id: '4',
        workOrder: 'WO-004',
        customer: 'Bob',
        vehicle: 'Kawasaki Ninja',
        plate: 'F 1111 AAA',
        service: 'Full Service',
        schedule: DateTime(2024, 12, 20),
        mechanic: 'Sandi',
        price: 500000,
        status: WorkStatus.done,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: doneWork),
          ),
        ),
      );

      // Assert
      expect(find.text('SELESAI'), findsOneWidget);
    });

    testWidgets('should have Detail button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('Detail'), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsWidgets);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should handle null schedule date', (WidgetTester tester) async {
      // Arrange
      final noScheduleWork = WorkItem(
        id: '5',
        workOrder: 'WO-005',
        customer: 'Charlie',
        vehicle: 'Honda Vario',
        plate: 'B 2222 CCC',
        service: 'Check Up',
        schedule: null,
        mechanic: 'Tono',
        price: 100000,
        status: WorkStatus.pending,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: noScheduleWork),
          ),
        ),
      );

      // Assert: Should display "-" for null date
      expect(find.text('-'), findsWidgets);
    });

    testWidgets('should display CUSTOMER label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('CUSTOMER'), findsOneWidget);
    });

    testWidgets('should display KENDARAAN label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('KENDARAAN'), findsOneWidget);
    });

    testWidgets('should display PLAT label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('PLAT'), findsOneWidget);
    });

    testWidgets('should display ESTIMASI label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkCard(item: testWorkItem),
          ),
        ),
      );

      // Assert
      expect(find.text('ESTIMASI'), findsOneWidget);
    });
  });

  group('WorkStatusChip Widget Tests', () {
    testWidgets('should display chip label', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkStatusChip(
              label: 'Semua',
              icon: Icons.list,
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Semua'), findsOneWidget);
    });

    testWidgets('should respond to tap', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkStatusChip(
              label: 'Pending',
              icon: Icons.pending,
              selected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WorkStatusChip));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should show different style when selected',
        (WidgetTester tester) async {
      // Act - Not selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkStatusChip(
              label: 'Test',
              icon: Icons.check,
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Rebuild with selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkStatusChip(
              label: 'Test',
              icon: Icons.check,
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Widget exists
      expect(find.byType(WorkStatusChip), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });
}
