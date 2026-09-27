import 'package:flutter_test/flutter_test.dart';
import 'package:flowpdf/main.dart';
import 'package:flowpdf/data/repositories/book_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FlowPDF smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = BookRepository();
    await repository.init();

    await tester.pumpWidget(FlowPdfApp(bookRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('FlowPDF'), findsOneWidget);
    expect(find.text('Tu biblioteca comienza aquí'), findsOneWidget);
  });
}
