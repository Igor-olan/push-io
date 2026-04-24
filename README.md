# PUSH.IO - Flutter Game

A mobile battle arena game where players are circles that push each other off a shrinking map.

## 📱 Screens

1. **Home Screen** - Username input + PLAY NOW / SETTING / HOW TO PLAY
2. **Settings Screen** - Master/BGM/SFX volume sliders, vibration toggle, left/right hand toggle
3. **In-Game Menu** - Same as settings but with "Return to menu" button
4. **How to Play** - Explains controls and game rules
5. **Gameplay** - Real-time physics-based pushing game with joystick + SPRINT + DASH
6. **Result (Lose)** - "You Are Dead" with kills & survive time stats
7. **Result (Win)** - "You Win!" with confetti particles

## 🎮 Gameplay Features

- **Joystick movement** - Virtual joystick on bottom left (swappable for left-hand mode)
- **Sprint button** - Hold to move faster (2.2x speed)
- **Dash button** - Leap forward with massive force, 1 second cooldown shown as progress ring
- **3 Bot opponents** with AI that chases and dashes at you
- **Shrinking map** - Arena shrinks every 10 seconds
- **3-minute match** timer
- **Physics collisions** with realistic bounce and momentum transfer
- **Player alive list** shown in top-right HUD

## 🚀 Setup

```bash
flutter pub get
flutter run
```

## 📦 Dependencies

- `shared_preferences` - Save settings
- `google_fonts` - Typography
- `flutter_animate` - Animations

## 🗂 Structure

```
lib/
├── main.dart              # App entry + routes
├── theme.dart             # Colors, text styles
├── game/
│   ├── game_logic.dart    # Player physics, GameState, Bot AI
│   ├── game_painter.dart  # Custom canvas rendering
│   └── settings.dart      # Settings singleton with persistence
├── screens/
│   ├── home_screen.dart
│   ├── settings_screen.dart   # Doubles as in-game pause menu
│   ├── how_to_play_screen.dart
│   ├── game_screen.dart
│   └── result_screen.dart
└── widgets/
    ├── joystick.dart     # Virtual joystick
    └── push_button.dart  # Animated game button
```
