import 'dart:async';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';

class Powerup extends SpriteComponent 
with HasGameReference<MyGame>, CollisionCallbacks {
  Powerup() : super(size: Vector2.all(200), anchor:  Anchor.center);

  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite('powerup.png');

    position += game.player.size / 2;

    add(CircleHitbox());

    final ScaleEffect pulsatingEffect = ScaleEffect.to(
      Vector2.all(1.1),
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,

      ),
      );
    add(pulsatingEffect);

    final OpacityEffect fadeOutEffect = OpacityEffect.fadeOut( // esto es para el efecto de desvanecimiento cuando se recoge el powerup
      EffectController(
        duration: 2.0,
        startDelay: 3.0,
      ),
      onComplete: (){
        removeFromParent();
        game.player.activePowerup = null;
      },
    );
    add(fadeOutEffect); //varias veces aplicamos este tipo de declaracion ya que este sirve para agregar efectos al componente



    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid){
      other.takeDamage();
    }
  }
}