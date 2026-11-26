import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_er_demo/main.dart';
import 'package:smart_er_demo/widgets/route_map.dart';

void main() {
  // Tests can't download map tiles.
  setUp(() => RouteMap.tilesEnabled = false);

  testWidgets('App starts on Trip Search', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartERApp());
    await tester.pump();

    expect(find.text('Trip Search'), findsOneWidget);
    expect(find.text('Find a ride'), findsOneWidget);
    expect(find.text('Post a ride'), findsOneWidget);
    expect(find.text('Track my own trip'), findsOneWidget);
  });

  testWidgets('Rider view shows the handshake pop-up on connect',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartERApp());
    await tester.pump();

    await tester.tap(find.text('Find a ride'));
    // The searching spinner never stops, so pump fixed amounts of time
    // instead of pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Looking for Alex M.'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Simulate connection'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Simulate connection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Handshake complete'), findsOneWidget);
    expect(find.text('Trip verified and logged'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
  });
}
