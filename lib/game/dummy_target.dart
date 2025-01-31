import 'package:flame/components.dart';

class DummyTarget extends PositionComponent {
  double speed = 5; // Adjust speed as needed

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt; // Moves continuously to the right
  }
}
