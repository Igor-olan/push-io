import 'package:flutter/material.dart';
import '../theme.dart';
import '../game/settings.dart';
import '../widgets/push_button.dart';

class SettingsScreen extends StatefulWidget {
  final bool isInGame;
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    this.isInGame = false,
    this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GameSettings _settings = GameSettings();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _settings.load();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                widget.isInGame ? 'MENU' : 'SETTINGS',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _VolumeSlider(
                    label: 'Master',
                    value: _settings.masterVolume,
                    onChanged: (v) => _settings.masterVolume = v,
                  ),
                  const SizedBox(height: 20),
                  _VolumeSlider(
                    label: 'BGM',
                    value: _settings.bgmVolume,
                    onChanged: (v) => _settings.bgmVolume = v,
                  ),
                  const SizedBox(height: 20),
                  _VolumeSlider(
                    label: 'SFX',
                    value: _settings.sfxVolume,
                    onChanged: (v) => _settings.sfxVolume = v,
                  ),
                  const SizedBox(height: 36),
                  // Vibration + Handedness
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ToggleCard(
                        icon: Icons.phone_android,
                        label: 'Vibration',
                        isActive: _settings.vibration,
                        onTap: () =>
                            _settings.vibration = !_settings.vibration,
                        showVibrationBars: true,
                      ),
                      const SizedBox(width: 32),
                      _ToggleCard(
                        icon: _settings.rightHanded
                            ? Icons.back_hand
                            : Icons.back_hand_outlined,
                        label: _settings.rightHanded ? 'Right' : 'Left',
                        isActive: true,
                        onTap: () =>
                            _settings.rightHanded = !_settings.rightHanded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // Reset button
                  PushButton(
                    label: 'Reset to default',
                    onPressed: () => _settings.resetToDefault(),
                  ),
                  if (widget.isInGame) ...[
                    const SizedBox(height: 12),
                    PushButton(
                      label: 'Return to menu',
                      onPressed: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppColors.accent.withOpacity(0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showVibrationBars;

  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showVibrationBars = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.accent.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showVibrationBars) ...[
                  Positioned(
                    left: 8,
                    child: Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
                Icon(
                  icon,
                  color: isActive ? AppColors.accent : AppColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.white : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
