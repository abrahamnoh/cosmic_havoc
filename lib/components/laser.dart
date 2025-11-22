import 'dart:async';
import 'dart:math';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame>,CollisionCallbacks {
  Laser({required super.position, super.angle = 0.0}) 
  : super(
    anchor: Anchor.center,
    priority: -1, 
    );

    @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');

    size *= 0.25;
    add(RectangleHitbox());

    return super.onLoad();
  }
  @override
  void update(double dt) { // esto es para mover el láser hacia arriba y eliminarlo si sale de la pantalla
    position += Vector2(sin(angle), -cos(angle)) * 500 *dt; //esto es para mover el láser en la dirección que apunta

    // remove the laser from the game 
    if (position.y < -size.y / 2) {
      removeFromParent();
    }
        super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      // Remove both the laser and the asteroid from the game
      removeFromParent();
      other.takeDamage();
    }
  }
}