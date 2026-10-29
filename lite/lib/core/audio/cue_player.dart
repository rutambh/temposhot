import 'package:audioplayers/audioplayers.dart';

/// Plays the bundled start/par cue. The asset is local and tiny; no network
/// access is involved. Platform audio failures are swallowed because the
/// visible timer must keep working even if audio is muted or unavailable.
class CuePlayer {
  /// Widget tests have no audio platform implementation. They switch this off
  /// so constructing a timer never starts an unavailable plugin channel.
  static bool enabled = true;

  AudioPlayer? _player;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  Future<void> beep() async {
    if (!enabled) return;
    try {
      await _audio.stop();
      await _audio.play(AssetSource('audio/beep.wav'), volume: 1.0);
    } catch (_) {
      // A missing audio device must never break the timer.
    }
  }

  Future<void> dispose() async {
    final player = _player;
    if (player == null) return;
    await player.dispose();
  }
}
