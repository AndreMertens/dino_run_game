import 'package:dino_run_game/game/dino.dart';
import 'package:dino_run_game/models/modus_settings.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:hive/hive.dart';

import '../models/level.dart';
import '../models/player_data.dart';
import '../models/settings.dart';
import '../widgets/game_over_menu.dart';
import '../widgets/hud.dart';
import 'audio_manager.dart';
import 'dummy_target.dart';
import 'enemy_manager.dart';

// This is the main flame game class.
class DinoRun extends FlameGame with TapDetector, HasCollisionDetection {
  final ModusSettings modusSettings;

  DinoRun({required this.modusSettings, super.camera, super.world});

  // List of all the audio assets.
  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
    'bounce.wav',
  ];

  late Dino _dino;

  late EnemyManager _enemyManager;

  late PlayerData playerData;

  late Settings settings;
  late final DummyTarget target;

  int counter = 0;

  // This method get called while flame is preparing this game.

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    // Makes the game full screen and landscape only.
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    // Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();

    settings = await _readSettings();
    world = World();
    add(world);
    camera = CameraComponent.withFixedResolution(width: 800, height: 500);
    camera.world = world;

    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize [AudioManager].
    await AudioManager.instance.init(
      _audioAssets,
      settings,
    );

    target = DummyTarget();
    add(target);

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');

    // Cache all the images.
    //await images.loadAll(_imageAssets);
    // Load all images into cache
    await images.loadAllImages();
    _loadLevel();
    world = Level(levelName: 'Frapp-02');

    // This makes the camera look at the center of the viewport.
    //camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    // Add the parallax as the backdrop.
  }

  void startGamePlay() {
    _dino = Dino(
        image: images.fromCache('FrappDinoSprites-tard.png'),
        modusSettings: modusSettings);
    camera.follow(_dino);

    // Timer to decide when to spawn next enemy.
    Timer timer = Timer(2, repeat: true);

    if (modusSettings.modus == ModusType.hard) {
      timer = Timer(1.5, repeat: true);
    }

    _enemyManager = EnemyManager(modusSettings: modusSettings, timer: timer);
    world.add(_dino);
    world.add(_enemyManager);
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level level = Level(levelName: 'Frapp-02');
      add(level);
      camera.add(level);
    });
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  //This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    //If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      //In such cases store default values in hive.
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    _dino.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();
  }

// This method reset the whole game world to initial state.
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to initial values.
    playerData.currentScore = 0;
    playerData.lives = 5;
  }

// This method gets called for each tick/frame of the game.
  @override
  void update(double dt) {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  // This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('DinoRun.Settings')!;
  }
}
