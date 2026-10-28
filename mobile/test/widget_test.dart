import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tra_mobile/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TramobileApp(),
      ),
    );

    expect(find.text('TRA'), findsOneWidget);
    expect(find.text('Multi-Agent Council'), findsOneWidget);
  });
}
