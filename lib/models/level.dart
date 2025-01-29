import 'dart:async';

import 'package:dino_run_game/game/dino_run.dart';
import 'package:dino_run_game/models/collision_block.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'background_tile.dart';
import 'fruits.dart';

class Level extends World with HasGameRef<DinoRun> {
  final String levelName;
  Level({
    required this.levelName,
  });
  late TiledComponent level;
  late ScrollingBackground scrollingBackground;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    scrollingBackground = ScrollingBackground(level);
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          // case 'Saw':
          //   final isVertical = spawnPoint.properties.getValue('isVertical');
          //   final offNeg = spawnPoint.properties.getValue('offNeg');
          //   final offPos = spawnPoint.properties.getValue('offPos');
          //   final saw = Saw(
          //     isVertical: isVertical,
          //     offNeg: offNeg,
          //     offPos: offPos,
          //     position: Vector2(spawnPoint.x, spawnPoint.y),
          //     size: Vector2(spawnPoint.width, spawnPoint.height),
          //   );
          //   add(saw);
          //   break;
          // case 'Trampoline':
          //   final trampoline = Trampoline(
          //     position: Vector2(spawnPoint.x, spawnPoint.y),
          //     size: Vector2(spawnPoint.width, spawnPoint.height),
          //   );
          // add(trampoline);
          // break;
          // case 'Checkpoint':
          //   final checkpoint = Checkpoint(
          //     position: Vector2(spawnPoint.x, spawnPoint.y),
          //     size: Vector2(spawnPoint.width, spawnPoint.height),
          //   );
          //   add(checkpoint);
          //   break;
          // case 'Chicken':
          //   final offNeg = spawnPoint.properties.getValue('offNeg');
          //   final offPos = spawnPoint.properties.getValue('offPos');
          //   final chicken = Chicken(
          //     position: Vector2(spawnPoint.x, spawnPoint.y),
          //     size: Vector2(spawnPoint.width, spawnPoint.height),
          //     offNeg: offNeg,
          //     offPos: offPos,
          //   )
          //;
          //   add(chicken);
          //   break;
          // case 'Turtle':
          //   final turtle = Turtle(
          //     position: Vector2(spawnPoint.x, spawnPoint.y),
          //     size: Vector2(spawnPoint.width, spawnPoint.height),
          //   );
          //   add(turtle);
          //   break;
          // default:
          //   break;
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
  }
}

class ScrollingBackground extends PositionComponent {
  final TiledComponent map;
  double speed = 50; // Adjust the speed as needed

  ScrollingBackground(this.map) {
    add(map);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the map to the left
    map.position.x -= speed * dt;

    // Reset position for infinite scrolling (if needed)
    if (map.position.x <= -map.size.x) {
      map.position.x = 0;
    }
  }
}
