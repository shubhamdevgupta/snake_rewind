import 'package:flutter/material.dart';

import '../../core/theme/theme_manager.dart';
import '../services/loading_controller.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  const GlobalLoadingOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LoadingController.instance,
      builder: (context, _) {
        final loading = LoadingController.instance;
        final theme = ThemeManager.instance.theme;

        return Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !loading.isLoading,
                child: AnimatedOpacity(
                  opacity: loading.isLoading ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: loading.isLoading
                      ? ColoredBox(
                          color: theme.scaffold.withValues(alpha: 0.72),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 24,
                              ),
                              decoration: BoxDecoration(
                                color: theme.uiSecondary,
                                border: Border.all(
                                  color: theme.boardBorder,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.uiAccent,
                                    ),
                                  ),
                                  if (loading.message != null) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      loading.message!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme.textOnSurface,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
