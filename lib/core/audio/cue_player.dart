import 'package:audioplayers/audioplayers.dart';

/// Plays the bundled start and par buzzer cues from `assets/audio/beep.wav`.
///
/// Guaranteed zero network; audio failures are caught silently to prevent timer interruption.
class CuePlayer {
  /// Disabled during headless widget tests.
  static bool enabled = true;

  AudioPlayer? _player;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  Future<void> beep() async {
    if (!enabled) return;
    try {
      await _audio.stop();
      await _audio.play(AssetSource('audio/beep.wav'), volume: 1.0);
    } catch (_) {
      // Audio driver unavailability must never crash or pause the visual timer
    }
  }

  Future<void> dispose() async {
    final player = _player;
    if (player == null) return;
    await player.dispose();
  }
}
