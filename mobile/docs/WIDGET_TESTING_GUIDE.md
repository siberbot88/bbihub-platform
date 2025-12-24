# 📱 Panduan Widget Testing untuk Flutter

## 🎯 Apa itu Widget Testing?

Widget testing adalah jenis testing di Flutter yang memungkinkan Anda menguji widget secara terisolasi. Widget testing lebih cepat daripada integration testing dan lebih comprehensive daripada unit testing.

## ✅ Keuntungan Widget Testing

1. **Cepat** - Berjalan dalam milidetik
2. **Terisolasi** - Menguji satu widget tanpa dependencies eksternal
3. **Mudah di-debug** - Error langsung menunjuk ke masalah spesifik
4. **Cost-effective** - Tidak perlu device fisik atau emulator

## 📦 Setup

### 1. Dependency (Sudah termasuk secara default)

Pastikan `pubspec.yaml` Anda memiliki:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 2. Struktur Folder

```
mobile/
├── lib/
│   └── feature/
│       └── admin/
│           └── widgets/
│               └── service_logging/
│                   └── logging_summary_boxes.dart
└── test/
    └── widget/
        └── logging_summary_boxes_test.dart
```

## 🧪 Anatomi Widget Test

### Struktur Dasar

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nama Group Test', () {
    testWidgets('deskripsi test', (WidgetTester tester) async {
      // Arrange: Setup data
      
      // Act: Build widget
      await tester.pumpWidget(MyWidget());
      
      // Assert: Verify hasil
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
```

### Penjelasan Komponen

1. **`testWidgets`** - Function untuk membuat widget test
2. **`WidgetTester tester`** - Object untuk berinteraksi dengan widget
3. **`await tester.pumpWidget()`** - Render widget untuk testing
4. **`find`** - Mencari widget dalam widget tree
5. **`expect`** - Assertion untuk memverifikasi hasil

## 🔍 Finder Methods (find.xxx)

```dart
// Mencari berdasarkan teks
find.text('Hello World')

// Mencari berdasarkan widget type
find.byType(Container)

// Mencari berdasarkan key
find.byKey(Key('myKey'))

// Mencari berdasarkan icon
find.byIcon(Icons.add)

// Mencari berdasarkan widget instance
find.byWidget(myWidget)

// Mencari descendant
find.descendant(
  of: find.byType(Container),
  matching: find.text('Hello')
)
```

## ✔️ Matchers Umum

```dart
// Menemukan tepat 1 widget
expect(find.text('Hello'), findsOneWidget);

// Menemukan N widget
expect(find.byType(Container), findsNWidgets(3));

// Menemukan minimal 1 widget
expect(find.text('World'), findsWidgets);

// Tidak menemukan widget
expect(find.text('Missing'), findsNothing);

// Menemukan minimal N widget
expect(find.byType(Text), findsAtLeastNWidgets(1));
```

## 🎬 WidgetTester Actions

### Rendering

```dart
// Render widget pertama kali
await tester.pumpWidget(MyWidget());

// Trigger rebuild (untuk animasi/state changes)
await tester.pump();

// Tunggu duration tertentu
await tester.pump(Duration(seconds: 1));

// Tunggu sampai semua animasi selesai
await tester.pumpAndSettle();
```

### Interaksi User

```dart
// Tap widget
await tester.tap(find.text('Button'));
await tester.pump(); // Rebuild setelah tap

// Long press
await tester.longPress(find.byKey(Key('myButton')));

// Drag
await tester.drag(find.byType(ListView), Offset(0, -200));

// Enter text
await tester.enterText(find.byType(TextField), 'Hello');

// Scroll
await tester.scrollUntilVisible(
  find.text('Item 50'),
  500.0,
);
```

## 📋 Contoh Test Cases

### 1. Test Rendering Dasar

```dart
testWidgets('should render widget correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    ),
  );
  
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### 2. Test dengan Parameter

```dart
testWidgets('should display correct data', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UserCard(
          name: 'John Doe',
          age: 25,
        ),
      ),
    ),
  );
  
  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('25'), findsOneWidget);
});
```

### 3. Test Interaksi User

```dart
testWidgets('should increment counter on tap', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: CounterWidget()));
  
  // Verify initial state
  expect(find.text('0'), findsOneWidget);
  
  // Tap button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  // Verify updated state
  expect(find.text('1'), findsOneWidget);
});
```

### 4. Test dengan Provider/State Management

```dart
testWidgets('should update when provider changes', (WidgetTester tester) async {
  final mockProvider = MockMyProvider();
  
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<MyProvider>.value(
        value: mockProvider,
        child: MyWidget(),
      ),
    ),
  );
  
  // Test logic here
});
```

### 5. Test TextField Input

```dart
testWidgets('should accept text input', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginForm()));
  
  // Enter email
  await tester.enterText(
    find.byKey(Key('emailField')),
    'test@example.com'
  );
  
  // Enter password
  await tester.enterText(
    find.byKey(Key('passwordField')),
    'password123'
  );
  
  expect(find.text('test@example.com'), findsOneWidget);
  expect(find.text('password123'), findsOneWidget);
});
```

### 6. Test Navigation

```dart
testWidgets('should navigate to detail page', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: HomePage()));
  
  // Tap navigation button
  await tester.tap(find.text('Go to Details'));
  await tester.pumpAndSettle(); // Wait for navigation animation
  
  // Verify we're on detail page
  expect(find.byType(DetailPage), findsOneWidget);
});
```

### 7. Test Scrolling

```dart
testWidgets('should scroll to bottom', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LongListPage()));
  
  // Scroll to find item
  await tester.scrollUntilVisible(
    find.text('Item 100'),
    500.0,
    scrollable: find.byType(ListView),
  );
  
  expect(find.text('Item 100'), findsOneWidget);
});
```

## 🏃 Menjalankan Tests

### Command Line

```bash
# Run semua tests
flutter test

# Run test file spesifik
flutter test test/widget/logging_summary_boxes_test.dart

# Run dengan coverage
flutter test --coverage

# Run dengan watch mode (auto-rerun on changes)
flutter test --watch

# Run test dengan pattern tertentu
flutter test --plain-name "should display correct counts"
```

### VS Code

1. Install extension **Flutter** dari Dart Code
2. Klik icon play di samping test function
3. Atau klik kanan → **Run Tests**

## 🎯 Best Practices

### 1. Gunakan Arrange-Act-Assert Pattern

```dart
testWidgets('example test', (WidgetTester tester) async {
  // Arrange: Setup test data dan kondisi awal
  const testData = 'Hello';
  
  // Act: Lakukan aksi yang ingin ditest
  await tester.pumpWidget(MaterialApp(home: MyWidget(data: testData)));
  
  // Assert: Verify hasilnya
  expect(find.text(testData), findsOneWidget);
});
```

### 2. Beri Nama Test yang Descriptive

```dart
// ❌ Bad
testWidgets('test 1', ...);

// ✅ Good
testWidgets('should display error message when email is invalid', ...);
```

### 3. Group Related Tests

```dart
group('LoginForm Widget Tests', () {
  group('Email Validation', () {
    testWidgets('should show error for invalid email', ...);
    testWidgets('should accept valid email', ...);
  });
  
  group('Password Validation', () {
    testWidgets('should show error for short password', ...);
    testWidgets('should accept strong password', ...);
  });
});
```

### 4. Gunakan setUp dan tearDown

```dart
group('MyWidget Tests', () {
  late MockApi mockApi;
  
  setUp(() {
    mockApi = MockApi();
  });
  
  tearDown(() {
    mockApi.dispose();
  });
  
  testWidgets('test 1', (tester) async {
    // Use mockApi here
  });
});
```

### 5. Test Edge Cases

```dart
testWidgets('should handle empty list', ...);
testWidgets('should handle very long text', ...);
testWidgets('should handle null values', ...);
testWidgets('should handle network errors', ...);
```

### 6. Gunakan Keys untuk Widget yang Sulit Ditemukan

```dart
// In widget
TextField(
  key: Key('emailField'),
  // ...
)

// In test
await tester.enterText(find.byKey(Key('emailField')), 'test@test.com');
```

## 🐛 Debugging Tips

### 1. Print Widget Tree

```dart
testWidgets('debug test', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  // Print seluruh widget tree
  debugDumpApp();
  
  // Print render tree
  debugDumpRenderTree();
});
```

### 2. Take Screenshot (untuk debugging)

```dart
testWidgets('visual debug', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  // Ambil screenshot (disimpan di test folder)
  await expectLater(
    find.byType(MyWidget),
    matchesGoldenFile('my_widget.png'),
  );
});
```

### 3. Verify Widget Properties

```dart
testWidgets('check widget properties', (tester) async {
  await tester.pumpWidget(MyButton());
  
  final button = tester.widget<ElevatedButton>(
    find.byType(ElevatedButton)
  );
  
  expect(button.onPressed, isNotNull);
});
```

## 📊 Code Coverage

```bash
# Generate coverage report
flutter test --coverage

# Untuk melihat HTML report, install lcov:
# Windows (via Chocolatey): choco install lcov
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Buka di browser
# Windows:
start coverage/html/index.html
```

## 🚀 Contoh Real-World Test Suite

Lihat file: `test/widget/logging_summary_boxes_test.dart` untuk contoh lengkap testing widget `LoggingSummaryBoxes`.

## 📚 Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)

## ❓ FAQ

**Q: Kapan menggunakan Widget Test vs Integration Test?**
A: Widget test untuk UI components terisolasi, Integration test untuk full user flows.

**Q: Apakah perlu mock API calls dalam widget test?**
A: Ya, gunakan mock untuk isolasi dan kecepatan testing.

**Q: Berapa coverage yang ideal?**
A: Target minimal 80% untuk production code.

---

**Happy Testing! 🎉**
