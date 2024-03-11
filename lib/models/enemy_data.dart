import 'package:flame/extensions.dart';

enum EnemyType { angryPig, bat, rino, rock, blueBird }

// This class stores all the data
// necessary for creation of an enemy.
class EnemyData {
  final EnemyType type;
  final Image image;
  final int nFrames;
  final double stepTime;
  final Vector2 textureSize;
  final bool canFly;

  EnemyData({
    required this.type,
    required this.image,
    required this.nFrames,
    required this.stepTime,
    required this.textureSize,
    required this.canFly,
  });

  double _speedX = 0;

  double get speedX => _speedX;

  set speedX(double value) {
    _speedX = value;
  }
}
