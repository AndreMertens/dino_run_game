import 'dart:math';

import 'package:dino_run_game/models/modus_settings.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/game/enemy.dart';
import '/models/enemy_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class EnemyManager extends Component with HasGameReference<DinoRun> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  final Timer timer;

  final ModusSettings modusSettings;

  int previousEnemyIndex = -1;

  EnemyManager({required this.modusSettings, required this.timer}) {
    timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    int randomIndex = _random.nextInt(_data.length);

    if (previousEnemyIndex == 0 && randomIndex == 1) {
      randomIndex += 1;
    }
    if (modusSettings.modus == ModusType.hard &&
        previousEnemyIndex == 1 &&
        randomIndex == 3) {
      randomIndex -= 1;
    }
    final enemyData = _data.elementAt(randomIndex);

    previousEnemyIndex = randomIndex;

    switch (enemyData.type) {
      case EnemyType.angryPig:
        if (modusSettings.modus == ModusType.easy) {
          enemyData.speedX = 50;
        } else if (modusSettings.modus == ModusType.medium) {
          enemyData.speedX = 100;
        } else if (modusSettings.modus == ModusType.hard) {
          enemyData.speedX = 150;
        } else {
          enemyData.speedX = 50;
        }
        break;
      case EnemyType.bat:
        if (modusSettings.modus == ModusType.easy) {
          enemyData.speedX = 60;
        } else if (modusSettings.modus == ModusType.medium) {
          enemyData.speedX = 110;
        } else if (modusSettings.modus == ModusType.hard) {
          enemyData.speedX = 160;
        } else {
          enemyData.speedX = 60;
        }
        break;
      case EnemyType.rino:
        if (modusSettings.modus == ModusType.easy) {
          enemyData.speedX = 100;
        } else if (modusSettings.modus == ModusType.medium) {
          enemyData.speedX = 150;
        } else if (modusSettings.modus == ModusType.hard) {
          enemyData.speedX = 200;
        } else {
          enemyData.speedX = 100;
        }
        break;
      case EnemyType.rock:
        if (modusSettings.modus == ModusType.easy) {
          enemyData.speedX = 90;
        } else if (modusSettings.modus == ModusType.medium) {
          enemyData.speedX = 140;
        } else if (modusSettings.modus == ModusType.hard) {
          enemyData.speedX = 190;
        } else {
          enemyData.speedX = 40;
        }
        break;
      case EnemyType.blueBird:
        if (modusSettings.modus == ModusType.easy) {
          enemyData.speedX = 50;
        } else if (modusSettings.modus == ModusType.medium) {
          enemyData.speedX = 100;
        } else if (modusSettings.modus == ModusType.hard) {
          enemyData.speedX = 150;
        } else {
          enemyData.speedX = 40;
        }
      default:
        enemyData.speedX = 50;
        break;
    }

    final enemy = Enemy(enemyData, modusSettings);

    // Help in setting all enemies on ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      game.camera.viewport.virtualSize.x + 32,
      game.camera.viewport.virtualSize.y - 20,
    );

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;
    game.world.add(enemy);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initialize all the data.
      _data.addAll([
        EnemyData(
          type: EnemyType.angryPig,
          image: game.images.fromCache('AngryPig/Walk (36x30).png'),
          hitImage: game.images.fromCache('Disappearing (96x96).png'),
          nFrames: 16,
          stepTime: 0.1,
          textureSize: Vector2(36, 30),
          canFly: false,
        ),
        EnemyData(
          type: EnemyType.bat,
          image: game.images.fromCache('Bat/Flying (46x30).png'),
          hitImage: game.images.fromCache('Disappearing (96x96).png'),
          nFrames: 7,
          stepTime: 0.1,
          textureSize: Vector2(46, 30),
          canFly: true,
        ),
        EnemyData(
          type: EnemyType.rino,
          image: game.images.fromCache('Rino/Run (52x34).png'),
          hitImage: game.images.fromCache('Disappearing (96x96).png'),
          nFrames: 6,
          stepTime: 0.09,
          textureSize: Vector2(52, 34),
          canFly: false,
        ),
        EnemyData(
          type: EnemyType.rock,
          image: game.images.fromCache('Rock/Rock3_Run (22x18).png'),
          hitImage: game.images.fromCache('Disappearing (96x96).png'),
          nFrames: 14,
          stepTime: 0.05,
          textureSize: Vector2(22, 18),
          canFly: false,
        ),
        EnemyData(
          type: EnemyType.blueBird,
          image: game.images.fromCache('BlueBird/Flying (32x32).png'),
          hitImage: game.images.fromCache('Disappearing (96x96).png'),
          nFrames: 9,
          stepTime: 0.08,
          textureSize: Vector2(32, 32),
          canFly: true,
        )
      ]);
    }

    timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
