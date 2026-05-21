import 'package:flutter/material.dart';

import '../../core/constants/difficulty.dart';
import '../../data/services/analytics_service.dart';
import '../../core/models/game_settings.dart';
import '../../core/theme/game_themes.dart';
import '../../core/theme/theme_manager.dart';
import '../services/audio_service.dart';
import '../widgets/theme_preview_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = ThemeManager.instance.settings;
  }

  Future<void> _apply(GameSettings next) async {
    setState(() => _draft = next);
    await ThemeManager.instance.updateSettings(next);
    AudioService.muted = !next.soundEnabled;
    if (!next.soundEnabled) {
      await AudioService.stopMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance.theme;

    return Scaffold(
      backgroundColor: theme.scaffold,
      appBar: AppBar(
        backgroundColor: theme.scaffold,
        foregroundColor: theme.uiPrimary,
        title: const Text(
          'SETTINGS',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(theme, 'THEME'),
          ...GameThemes.all.map(
            (t) => ThemePreviewTile(
              theme: t,
              selected: _draft.themeId == t.id,
              onTap: () => _apply(_draft.copyWith(themeId: t.id)),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'DIFFICULTY'),
          _difficultyRow(theme),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'GAMEPLAY'),
          _switch(
            theme,
            'Smooth movement',
            'Interpolated snake glide between cells',
            _draft.smoothMovement,
            (v) => _apply(_draft.copyWith(smoothMovement: v)),
          ),
          _switch(
            theme,
            'Show grid lines',
            'LCD cell grid on the board',
            _draft.showGrid,
            (v) => _apply(_draft.copyWith(showGrid: v)),
          ),
          _switch(
            theme,
            'CRT / scanline effect',
            'Retro screen overlay during play',
            _draft.crtEffect,
            (v) => _apply(_draft.copyWith(crtEffect: v)),
          ),
          _switch(
            theme,
            'Retro status bar',
            'Nokia-style clock & battery on home',
            _draft.retroStatusBar,
            (v) => _apply(_draft.copyWith(retroStatusBar: v)),
          ),
          _switch(
            theme,
            'High performance',
            'Full effects & smooth rendering',
            _draft.highPerformanceMode,
            (v) => _apply(_draft.copyWith(highPerformanceMode: v)),
          ),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'AUDIO & HAPTICS'),
          _switch(
            theme,
            'Sound effects & music',
            null,
            _draft.soundEnabled,
            (v) => _apply(_draft.copyWith(soundEnabled: v)),
          ),
          _switch(
            theme,
            'Vibration',
            'Haptic feedback on actions',
            _draft.vibrationEnabled,
            (v) => _apply(_draft.copyWith(vibrationEnabled: v)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(dynamic theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: theme.uiAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _difficultyRow(dynamic theme) {
    return Row(
      children: Difficulty.values.map((d) {
        final sel = _draft.difficulty == d;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: sel ? theme.uiPrimary : theme.uiSecondary,
              child: InkWell(
                onTap: () async {
                  await AnalyticsService.logDifficultySelected(d.name);
                  await _apply(_draft.copyWith(difficulty: d));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.boardBorder, width: 2),
                  ),
                  child: Text(
                    d.label,
                    style: TextStyle(
                      color: sel ? theme.scaffold : theme.uiPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _switch(
    dynamic theme,
    String title,
    String? subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: theme.uiPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: theme.uiPrimary.withValues(alpha: 0.6),
                  fontSize: 11))
          : null,
      value: value,
      activeThumbColor: theme.uiAccent,
      onChanged: onChanged,
    );
  }
}
