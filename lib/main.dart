// Student: Myles Miller
// Activity 07 Digital Pet State Lab, October 2026.
import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_state.dart';

void main() => runApp(const DigitalPetApp());

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Digital Pet',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF23745B)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F7F3),
    ),
    home: const PetScreen(),
  );
}

class PetScreen extends StatefulWidget {
  const PetScreen({
    super.key,
    this.hungerInterval = const Duration(seconds: 30),
    this.winDuration = const Duration(minutes: 3),
  });
  final Duration hungerInterval;
  final Duration winDuration;
  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  PetState _pet = const PetState();
  late final TextEditingController _nameController;
  Timer? _hungerTimer, _winTimer, _bounceTimer;
  Duration _highMoodElapsed = Duration.zero;
  DateTime? _highMoodStarted;
  bool _paused = false, _bouncing = false;
  int _bounceGeneration = 0;
  String _lastAction = 'Care for your new friend.';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _pet.name);
    _startHungerTimer();
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();
    if (_paused || !_pet.isPlaying) return;
    _hungerTimer = Timer.periodic(widget.hungerInterval, (_) {
      if (!mounted || _paused || !_pet.isPlaying) return;
      _apply(_pet.hungerTick(), 'Time passed. Hunger increased.');
    });
  }

  void _syncWinTimer() {
    if (!_pet.isPlaying || _pet.happiness <= 80) {
      _winTimer?.cancel();
      _winTimer = null;
      _highMoodElapsed = Duration.zero;
      _highMoodStarted = null;
      if (!_pet.isPlaying) _hungerTimer?.cancel();
      return;
    }
    if (_paused || _winTimer != null) return;
    _highMoodStarted = DateTime.now();
    _winTimer = Timer(widget.winDuration - _highMoodElapsed, () {
      _winTimer = null;
      if (!mounted || _paused || !_pet.isPlaying || _pet.happiness <= 80) {
        return;
      }
      setState(() {
        _pet = _pet.win();
        _lastAction = 'Amazing! Your pet stayed happy for three minutes.';
      });
      _hungerTimer?.cancel();
    });
  }

  void _apply(PetState next, String description, {bool bounce = false}) {
    if (!_pet.isPlaying || _paused) return;
    setState(() {
      _pet = next;
      _lastAction = description;
    });
    _syncWinTimer();
    if (bounce) _bounce();
  }

  void _bounce() {
    _bounceTimer?.cancel();
    final generation = ++_bounceGeneration;
    setState(() => _bouncing = true);
    _bounceTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted || generation != _bounceGeneration) return;
      setState(() => _bouncing = false);
    });
  }

  void _togglePause() {
    if (!_pet.isPlaying) return;
    if (!_paused) {
      _hungerTimer?.cancel();
      _winTimer?.cancel();
      _winTimer = null;
      if (_highMoodStarted != null) {
        _highMoodElapsed += DateTime.now().difference(_highMoodStarted!);
        _highMoodStarted = null;
      }
      setState(() {
        _paused = true;
        _lastAction = 'Care timers paused.';
      });
    } else {
      setState(() {
        _paused = false;
        _lastAction = 'Care timers resumed.';
      });
      _startHungerTimer();
      _syncWinTimer();
    }
  }

  void _reset() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _bounceTimer?.cancel();
    _winTimer = null;
    _highMoodStarted = null;
    _highMoodElapsed = Duration.zero;
    setState(() {
      _pet = const PetState();
      _nameController.text = _pet.name;
      _paused = false;
      _bouncing = false;
      _lastAction = 'A fresh start for Pip!';
    });
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _bounceTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  String get _moodLabel => switch (_pet.mood) {
    PetMood.happy => 'Happy',
    PetMood.neutral => 'Neutral',
    PetMood.unhappy => 'Unhappy',
  };
  Color get _moodColor => switch (_pet.mood) {
    PetMood.happy => const Color(0xFF48A57B),
    PetMood.neutral => const Color(0xFFFFD269),
    PetMood.unhappy => const Color(0xFFEB776C),
  };
  String get _speech {
    if (_pet.outcome == PetOutcome.won) return 'Best day ever!';
    if (_pet.outcome == PetOutcome.lost) return 'I need a fresh start.';
    if (_paused) return 'I will wait right here.';
    if (_pet.hunger > 80) return "I'm hungry. Feed me!";
    if (_pet.mood == PetMood.unhappy) return 'Could we play together?';
    if (_pet.mood == PetMood.happy) return 'I love our time together!';
    return "Hi, I'm ${_pet.name}!";
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animation = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 250);
    final moodScale = _pet.mood == PetMood.happy
        ? 1.04
        : _pet.mood == PetMood.unhappy
        ? .95
        : 1.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        actions: [
          IconButton(
            tooltip: 'Restart pet',
            icon: const Icon(Icons.restart_alt),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Meet ${_pet.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  'A little care goes a long way',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Semantics(
                          label: '${_pet.name}, $_moodLabel mood',
                          image: true,
                          child: AnimatedScale(
                            duration: animation,
                            scale:
                                moodScale *
                                (_bouncing && !reduceMotion ? 1.09 : 1),
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  _moodColor,
                                  BlendMode.modulate,
                                ),
                                child: Image.asset(
                                  'assets/pet.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Chip(label: Text('Mood: $_moodLabel')),
                        AnimatedSwitcher(
                          duration: animation,
                          child: Text(
                            _speech,
                            key: ValueKey(_speech),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _Meter(
                          label: 'Happiness',
                          value: _pet.happiness,
                          color: const Color(0xFF218360),
                          duration: animation,
                        ),
                        const SizedBox(height: 16),
                        _Meter(
                          label: 'Hunger',
                          value: _pet.hunger,
                          color: const Color(0xFFC46A32),
                          duration: animation,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _pet.outcome == PetOutcome.won
                      ? 'You won!'
                      : _pet.outcome == PetOutcome.lost
                      ? 'Game over'
                      : _paused
                      ? 'Paused'
                      : 'Ready to care',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(_lastAction, textAlign: TextAlign.center),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _pet.isPlaying && !_paused
                          ? () => _apply(
                              _pet.feed(),
                              'You fed ${_pet.name}.',
                              bounce: true,
                            )
                          : null,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                    FilledButton.icon(
                      onPressed: _pet.isPlaying && !_paused
                          ? () => _apply(
                              _pet.play(),
                              'You played with ${_pet.name}.',
                              bounce: true,
                            )
                          : null,
                      icon: const Icon(Icons.sports_tennis),
                      label: const Text('Play'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pet.isPlaying ? _togglePause : null,
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                      label: Text(_paused ? 'Resume' : 'Pause'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Pet name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _rename(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _rename,
                    icon: const Icon(Icons.check),
                    label: const Text('Save name'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep happiness above 80 for 3 minutes to win. Hunger rises every 30 seconds. '
                  'If hunger reaches 100 and happiness falls to 10 or below, the game ends.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _rename() {
    if (!_pet.isPlaying) return;
    setState(() {
      _pet = _pet.rename(_nameController.text);
      _lastAction = 'Your pet is now ${_pet.name}.';
    });
    FocusScope.of(context).unfocus();
  }
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.label,
    required this.value,
    required this.color,
    required this.duration,
  });
  final String label;
  final int value;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label $value out of 100',
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '$value / 100',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 7),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value / 100),
          duration: duration,
          builder: (context, progress, child) => LinearProgressIndicator(
            minHeight: 12,
            borderRadius: BorderRadius.circular(20),
            value: progress,
            color: color,
          ),
        ),
      ],
    ),
  );
}
