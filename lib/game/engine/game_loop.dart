/// Fixed timestep accumulator — decouples frame rate from game logic ticks.
///
/// At 60 FPS, [dt] ≈ 0.016s. Snake still moves once every [stepSeconds]
/// regardless of frame drops, keeping gameplay speed consistent.
class GameLoop {
  double _accumulator = 0;

  void reset() => _accumulator = 0;

  /// Calls [onTick] zero or more times per frame when enough time elapsed.
  void update({
    required double dt,
    required double stepSeconds,
    required void Function() onTick,
  }) {
    if (stepSeconds <= 0) return;
    _accumulator += dt;
    while (_accumulator >= stepSeconds) {
      _accumulator -= stepSeconds;
      onTick();
    }
  }
}
