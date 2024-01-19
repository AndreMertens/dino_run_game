import 'package:flame_audio/flame_audio.dart';

// This class is the common interface between [DinoRun]
// and [Flame] engine's audio APIs.
class AudioManager {
  // 78.
  AudioManager._internal();

  // [_instance] represents the single static instance of [AudioManager].
  static final AudioManager _instance = AudioManager._internal();

  // A getter to access the single instance of [AudioManager].
  static AudioManager get instance => _instance;

  // This method is responsible for initializing caching given list of [files],
  // and initializing settings.
  Future<void> init(
    List<String> files,
    // 79.
  ) async {
    // 80.
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(files);
  }

  // Starts the given audio file as BGM on loop.
  void startBgm(String fileName) {
    FlameAudio.bgm.play(fileName, volume: 0.4);
    // 81.
  }

  // Pauses currently playing BGM if any.
  void pauseBgm() {
    FlameAudio.bgm.pause();
    // 82.
  }

  // Resumes currently paused BGM if any.
  void resumeBgm() {
    FlameAudio.bgm.resume();
    // 83.
  }

  // Stops currently playing BGM if any.
  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  // Plays the given audio file once.
  void playSfx(String fileName) {
    FlameAudio.play(fileName);
    // 84.
  }
}
