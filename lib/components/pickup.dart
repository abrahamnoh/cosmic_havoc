//este archivo define la clase Pickup que representa los objetos que el jugador puede recoger en el juego.
import 'dart:async';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';

enum PickupType { bomb, laser, powerup }

class Pickup extends SpriteComponent with HasGameReference<MyGame> {
  final PickupType pickupType;


  Pickup({required super.position, required this.pickupType})
      : super(size: Vector2.all(100), anchor: Anchor.center);


      @override
      FutureOr<void> onLoad() async{
        sprite = await game.loadSprite('${pickupType.name}_pickup.png'); 

    add(CircleHitbox());


    final ScaleEffect pulsatingEffect = ScaleEffect.to( // esto es para crear un efecto de pulsación en el pickup y hacer que sea más llamativo
      Vector2.all(0.9),
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
      
      );
    add(pulsatingEffect);



    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += 300 * dt; // Velocidad de caída del pickup

    //remove the pickup from the game if it goes below the bottom
    if (position.y > game.size.y + size.y / 2){
      removeFromParent();
    }

    
  }
}