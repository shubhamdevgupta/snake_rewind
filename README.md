# Snake Xenzia — Classic Nokia Snake (Flutter + Flame)

Production-ready retro Snake inspired by Nokia keypad phones. Built with **Flutter**, **Flame** game engine, and clean modular architecture.

## Features

### Gameplay
- Smooth 60 FPS gameplay (Flame render loop — no per-tick `setState`)
- Fixed timestep game logic with delta accumulation
- Input buffering (up to 3 queued turns) — no missed arrow keys
- Keyboard (arrows + WASD), swipe, and retro D-pad
- Easy / Medium / Hard difficulty + score multipliers
- Persistent high score (SharedPreferences)
- Retro SFX, background music, haptics, mute toggle
- Game over stats, pause/resume, restart

### Social & cloud (Phase 2)
- Firebase Auth — **Guest** or **Google** (optional, not forced)
- Cloud Firestore — profiles, leaderboards, achievements, stats
- Global / Weekly / Theme / Friends leaderboards
- Achievement system with progress sync
- Statistics screen with charts
- Analytics + Crashlytics
- Daily challenge infrastructure, friends hub

See [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) for console configuration.

## Architecture

```
lib/
├── main.dart, app_root.dart
├── core/firebase/          # Init, options
├── core/theme/             # Themes + ThemeManager
├── data/
│   ├── models/             # UserProfile, LeaderboardEntry, etc.
│   ├── repositories/       # Auth, User, Leaderboard, Achievement
│   ├── services/           # Analytics, Crashlytics, Auth, Progression
│   └── achievements/       # Catalog + engine
├── features/               # Welcome, Profile, Leaderboard, …
├── game/                   # Existing Flame game (unchanged feel)
└── shared/widgets/         # RetroScreenShell, menu tiles
```

### Performance design

| Before | After |
|--------|--------|
| `Timer` + `notifyListeners()` every tick | Flame `update()` + `render()` |
| Full widget tree rebuild ~5–10×/sec | Only `ValueNotifier` for score |
| Flutter `CustomPaint` in widget tree | Canvas draw on game thread |

## Setup

```bash
flutter pub get
python tool/generate_sounds.py   # creates assets/audio/*.wav
flutter run
```

## Profile / DevTools

```bash
flutter run --profile
```

Open **DevTools → Performance → Flutter frames**. Target: bars under **17 ms** (60 FPS), minimal orange jank.

## Build release (Play Store)

```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release

# APK
flutter build apk --release
```

Output:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### Signing (release)

1. Place `upload-keystore.jks` in the `android/` folder.
2. Copy `android/keystore.properties.example` → `android/keystore.properties` and set passwords.
3. Build:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Never commit** `keystore.properties` or `*.jks` to a public repository.

## Tests

```bash
flutter test
flutter analyze
```

## Assets

```
assets/audio/
  click.wav
  eat.wav
  game_over.wav
  bg.wav
```

## License

MIT — portfolio / learning use.
