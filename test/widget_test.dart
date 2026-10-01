import 'package:digital_pet_07/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('care actions, pause, restart, and name update are visible', (
    tester,
  ) async {
    await tester.pumpWidget(const DigitalPetApp());
    expect(find.text('50 / 100'), findsNWidgets(2));
    await tester.scrollUntilVisible(find.text('Play'), 200);
    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(find.text('65 / 100'), findsOneWidget);
    expect(find.text('60 / 100'), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Feed'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Resume'));
    await tester.pump();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Mochi');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pump();
    expect(find.text('Meet Mochi'), findsOneWidget);
    await tester.tap(find.byTooltip('Restart pet'));
    await tester.pump();
    expect(find.text('Meet Pip'), findsOneWidget);
    expect(find.text('50 / 100'), findsNWidgets(2));
  });

  testWidgets('three-minute rule cancels at 80 and restarts after crossing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PetScreen(
          hungerInterval: Duration(hours: 1),
          winDuration: Duration(seconds: 3),
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('Play'), 200);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Play'));
      await tester.pump();
    }
    expect(find.text('95 / 100'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Feed'));
      await tester.pump();
    }
    expect(find.text('80 / 100'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('You won!'), findsNothing);
    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('You won!'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Feed'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('reduced motion removes optional animation durations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: DigitalPetApp(),
      ),
    );
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
      Duration.zero,
    );
    for (final tween in tester.widgetList<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    )) {
      expect(tween.duration, Duration.zero);
    }
  });
}
