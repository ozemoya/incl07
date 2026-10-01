# Digital Pet State Lab

A Flutter pet-care app for In-Class Activity 07. The pet has one source of truth for its name, happiness, hunger, and outcome. Feed and Play update the meters; a 30-second timer raises hunger; a three-minute continuous stretch above 80 happiness wins the game. Hunger at 100 with happiness at 10 or lower ends the game.

## Team and workstreams

- Myles Miller, undergraduate, care systems and initial integrated app.
- Eziz Bagshiyev, pet personality workstream. His contribution and review links will be added after his work is integrated.

The commit history and pull requests are the record of actual contributions; this README does not claim a review or contribution that has not occurred.

## Features and learning outcomes

| Feature | What changes | Learning outcome | Evidence |
| --- | --- | --- | --- |
| Feed, Play, timers, and outcomes | The single `PetState` changes bounded meters and outcome; `PetScreen` schedules timers | `setState`, lifecycle, state boundaries | `test/pet_state_test.dart`, `test/widget_test.dart` |
| Pause and Resume | Suspends hunger and win timers, saves elapsed high-mood time, resumes once | Timer ownership and lifecycle | Widget interaction test; [paused emulator screenshot](docs/images/portrait-paused.png) |
| Visual polish and accessible motion | Mood-based tint and size, bounce, smooth meters, speech transitions; reduced-motion mode removes animation | Derived UI and accessible feedback | Mood threshold and reduced-motion tests; [neutral](docs/images/portrait-initial.png) and [happy](docs/images/portrait-happy.png) screenshots |

The selected undergraduate advanced features are **Session controls** and **Visual polish and accessible motion**. The second feature includes animated scaling and animated meters, with `MediaQuery.disableAnimations` support. Mood also appears as text, not only color.

## Rules

- Initial happiness 50, hunger 50.
- Feed reduces hunger by 10. If the resulting hunger is below 30, happiness drops by 20; otherwise it rises by 10.
- Play raises happiness by 15 and hunger by 10.
- Every 30 seconds, hunger rises by 5. A tick from 95 reaches 100 without a happiness penalty. A later overflow tick reduces happiness by 20.
- All meters are clamped to 0–100. A win requires happiness strictly above 80 for three continuous unpaused minutes. At 80 or below, the win countdown resets.
- A loss occurs at hunger 100 and happiness 10 or below. Win and loss disable care actions until Restart.

## Run and test

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

The app uses an original grayscale transparent PNG in `assets/pet.png`, drawn for this project by Myles Miller. It is tinted with `ColorFiltered` and `BlendMode.modulate`. No external pet art or font licenses are required.

## Test evidence

Automated tests cover feed/play bounds, mood thresholds 29/30/70/71, hunger overflow, loss freeze, reset, strict win threshold, timer cancellation and restart using a shorter test-only duration, visible care/pause/name actions, and reduced-motion durations. `flutter analyze` reports no issues; `flutter test` passes all seven tests.

On the Pixel 7 Pro emulator, I observed the 30-second tick take hunger from 50 to 55, three Play taps produce a happy green tint and 95 happiness, Pause disable care buttons, and the entire page scroll in landscape without an overflow. Screenshots: [initial portrait](docs/images/portrait-initial.png), [happy portrait](docs/images/portrait-happy.png), [paused portrait](docs/images/portrait-paused.png), [landscape top](docs/images/landscape.png), [landscape controls](docs/images/landscape-actions.png).

The release APK was built, installed on the same emulator, and launched. In that installed release, Play changed happiness from 50 to 65 and hunger from 50 to 60; Pause disabled Feed and Play. Evidence: [release opening screen](docs/images/release-portrait.png) and [release care check](docs/images/release-care.png). The submitted APK SHA-256 is `FA17BB2358CB9E956D0B7AD75D6DC9AE778934837BA28B55F005B23E8FCE1B10`.

## Collaboration

The work is tracked in [care systems issue #1](https://github.com/ozemoya/incl07/issues/1) and [pet personality issue #2](https://github.com/ozemoya/incl07/issues/2). Eziz was invited as a collaborator. His contribution and cross-team review remain pending; the repo history should be checked for actual work before calling the two-team collaboration complete.
