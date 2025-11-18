import 'dart:async';

import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame> {
  Laser({required super.position}) 
  : super(
    anchor: Anchor.center,
    priority: -1, 
    );

    @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');

    size *= 0.25;
    return super.onLoad();
  }
  @override
  void update(double dt) {
    position.y -= 500 * dt;

    // remove the laser from the game 
    if (position.y < -size.y / 2) {
      removeFromParent();
    }
        super.update(dt);
  }
}