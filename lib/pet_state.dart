enum PetOutcome { playing, won, lost }

enum PetMood { unhappy, neutral, happy }

/// Game rules are separate from the widget tree so boundaries are testable.
class PetState {
  const PetState({
    this.name = 'Pip',
    this.happiness = 50,
    this.hunger = 50,
    this.outcome = PetOutcome.playing,
  });

  final String name;
  final int happiness;
  final int hunger;
  final PetOutcome outcome;

  bool get isPlaying => outcome == PetOutcome.playing;
  PetMood get mood => happiness < 30
      ? PetMood.unhappy
      : happiness > 70
      ? PetMood.happy
      : PetMood.neutral;

  static int _bound(int value) => value.clamp(0, 100);

  PetState _with({
    String? name,
    int? happiness,
    int? hunger,
    PetOutcome? outcome,
  }) {
    final h = _bound(happiness ?? this.happiness);
    final u = _bound(hunger ?? this.hunger);
    final result =
        outcome ?? (u == 100 && h <= 10 ? PetOutcome.lost : this.outcome);
    return PetState(
      name: name ?? this.name,
      happiness: h,
      hunger: u,
      outcome: result,
    );
  }

  PetState rename(String text) {
    final trimmed = text.trim();
    return _with(name: trimmed.isEmpty ? name : trimmed);
  }

  PetState feed() {
    if (!isPlaying) return this;
    final nextHunger = _bound(hunger - 10);
    return _with(
      hunger: nextHunger,
      happiness: happiness + (nextHunger < 30 ? -20 : 10),
    );
  }

  PetState play() =>
      !isPlaying ? this : _with(happiness: happiness + 15, hunger: hunger + 10);

  PetState hungerTick() => !isPlaying
      ? this
      : _with(
          hunger: hunger + 5,
          happiness: hunger >= 100 ? happiness - 20 : happiness,
        );

  PetState win() =>
      isPlaying && happiness > 80 ? _with(outcome: PetOutcome.won) : this;

  PetState reset() => const PetState();
}
