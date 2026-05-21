import 'package:flutter/material.dart';

import '../../core/theme/game_theme_data.dart';
import '../models/direction.dart';
import 'retro_button.dart';

class ControlPad extends StatelessWidget {
  const ControlPad({
    super.key,
    required this.theme,
    required this.onDirection,
    this.enabled = true,
  });

  final GameThemeData theme;
  final void Function(Direction direction) onDirection;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    void go(Direction d) {
      if (enabled) onDirection(d);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(flex: 1),
            RetroButton(
              theme: theme,
              icon: Icons.keyboard_arrow_up,
              label: '',
              onPressed: enabled ? () => go(Direction.up) : null,
            ),
            const Spacer(flex: 1),
          ],
        ),
        Row(
          children: [
            RetroButton(
              theme: theme,
              icon: Icons.keyboard_arrow_left,
              label: '',
              onPressed: enabled ? () => go(Direction.left) : null,
            ),
            RetroButton(
              theme: theme,
              icon: Icons.keyboard_arrow_down,
              label: '',
              onPressed: enabled ? () => go(Direction.down) : null,
            ),
            RetroButton(
              theme: theme,
              icon: Icons.keyboard_arrow_right,
              label: '',
              onPressed: enabled ? () => go(Direction.right) : null,
            ),
          ],
        ),
      ],
    );
  }
}
