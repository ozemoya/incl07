import 'package:digital_pet_07/pet_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feed and play clamp values and apply the documented rules', () {
    final low = const PetState(hunger: 5, happiness: 10).feed();
    expect(low.hunger, 0);
    expect(low.happiness, 0);
    final high = const PetState(hunger: 95, happiness: 95).feed();
    expect(high.hunger, 85);
    expect(high.happiness, 100);
    final play = const PetState(hunger: 95, happiness: 95).play();
    expect(play.hunger, 100);
    expect(play.happiness, 100);
  });

  test('mood threshold is red below 30, yellow through 70, green above', () {
    expect(const PetState(happiness: 29).mood, PetMood.unhappy);
    expect(const PetState(happiness: 30).mood, PetMood.neutral);
    expect(const PetState(happiness: 70).mood, PetMood.neutral);
    expect(const PetState(happiness: 71).mood, PetMood.happy);
  });

  test(
    'hunger overflow reduces happiness, loss freezes actions, reset works',
    () {
      final atLimit = const PetState(hunger: 95, happiness: 30).hungerTick();
      expect(atLimit.hunger, 100);
      expect(atLimit.happiness, 30);
      final overflow = atLimit.hungerTick();
      expect(overflow.hunger, 100);
      expect(overflow.happiness, 10);
      expect(overflow.outcome, PetOutcome.lost);
      expect(overflow.play(), same(overflow));
      expect(overflow.reset().outcome, PetOutcome.playing);
    },
  );

  test('win requires strictly above 80', () {
    expect(const PetState(happiness: 80).win().outcome, PetOutcome.playing);
    expect(const PetState(happiness: 81).win().outcome, PetOutcome.won);
  });
}
