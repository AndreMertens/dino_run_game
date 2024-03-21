import 'package:dino_run_game/game/dino.dart';
import 'package:dino_run_game/models/modus_settings.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:hive/hive.dart';

import '../models/player_data.dart';
import '../models/settings.dart';
import '../widgets/game_over_menu.dart';
import '../widgets/hud.dart';
import 'audio_manager.dart';
import 'enemy_manager.dart';

// This is the main flame game class.
class DinoRun extends FlameGame with TapDetector, HasCollisionDetection {
  final ModusSettings modusSettings;

  DinoRun({super.camera, required this.modusSettings});

  // List of all the image assets.
  static const _imageAssets = [
    'DinoSprites - tard.png',
    'AngryPig/Walk (36x30).png',
    'Bat/Flying (46x30).png',
    'Rino/Run (52x34).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
    'parallax/plx-7.png',
    'parallax/plx-8.png',
    'parallax/plx-9.png',
    'parallax/plx-10.png',
    'parallax/plx-11.png',
    'parallax/plx-12.png',
    'Rock/Rock3_Run (22x18).png',
    'BlueBird/Flying (32x32).png',
    'Skeleton/Walk (150x150).png',
    'Goblin/Run (150x150).png',
    'FlyingTrunk/Flight (150x150).png',
    'Mushroom/Run (150x150).png',
  ];

  // List of all the audio assets.
  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  late Dino _dino;

  late EnemyManager _enemyManager;

  late PlayerData playerData;

  late Settings settings;

  ParallaxComponent parallaxBackground = ParallaxComponent();

  Vector2 get virtualSize => camera.viewport.virtualSize;

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    // Makes the game full screen and landscape only.
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    // Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();

    settings = await _readSettings();

    // Initialize [AudioManager].
    await AudioManager.instance.init(
      _audioAssets,
      settings,
    );

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // This makes the camera look at the center of the viewport.
    camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    /// Create a [ParallaxComponent] and add it to game.
    parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('parallax/plx-1.png'),
        ParallaxImageData('parallax/plx-2.png'),
        ParallaxImageData('parallax/plx-3.png'),
        ParallaxImageData('parallax/plx-4.png'),
        ParallaxImageData('parallax/plx-5.png'),
        ParallaxImageData('parallax/plx-6.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    // Add the parallax as the backdrop.
    camera.backdrop.add(parallaxBackground);
  }

  void startGamePlay() {
    _dino = Dino(
        image: images.fromCache('DinoSprites - tard.png'),
        modusSettings: modusSettings);

    // Timer to decide when to spawn next enemy.
    Timer _timer = Timer(2, repeat: true);

    if (modusSettings.modus == ModusType.hard) {
      _timer = Timer(1.5, repeat: true);
    }
    if (modusSettings.modus == ModusType.nightmare) {
      _timer = Timer(1, repeat: true);
    }

    _enemyManager = EnemyManager(modusSettings: modusSettings, timer: _timer);
    world.add(_dino);
    world.add(_enemyManager);
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

  void changeBackground() async {
    if (modusSettings.modus != ModusType.nightmare) {
      parallaxBackground = await loadParallaxComponent(
        [
          ParallaxImageData('parallax/plx-1.png'),
          ParallaxImageData('parallax/plx-2.png'),
          ParallaxImageData('parallax/plx-3.png'),
          ParallaxImageData('parallax/plx-4.png'),
          ParallaxImageData('parallax/plx-5.png'),
          ParallaxImageData('parallax/plx-6.png'),
        ],
        baseVelocity: Vector2(10, 0),
        velocityMultiplierDelta: Vector2(1.4, 0),
      );
    } else {
      parallaxBackground = await loadParallaxComponent(
        [
          ParallaxImageData('parallax/plx-7.png'),
          ParallaxImageData('parallax/plx-8.png'),
          ParallaxImageData('parallax/plx-9.png'),
          ParallaxImageData('parallax/plx-10.png'),
          ParallaxImageData('parallax/plx-11.png'),
          ParallaxImageData('parallax/plx-12.png'),
        ],
        baseVelocity: Vector2(10, 0),
        velocityMultiplierDelta: Vector2(1.4, 0),
      );
    }

    camera.backdrop.add(parallaxBackground);
  }
}
