import 'dart:async';
import 'dart:ui';

import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';


class Player extends SpriteComponent with HasGameReference<MyGame>{
  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite('player_blue_on0.png'); 


    size *= 0.3; //esto es para reducir el tamaño del jugador

    return super.onLoad();
  }

  @override
  void update(double dt) {
        super.update(dt);

    // Movimiento del jugador basado en el joystick
    position += game.joystick.relativeDelta.normalized() * 200 * dt; // esto es para mover el jugador a una velocidad de 200 pixels por segundo


    _handleScreenBounds(); //esto es para que el jugador no se salga de la pantalla, es una funcion 
  }

  void _handleScreenBounds() {
    final double screenWidth = game.size.x; // ancho de la pantalla
    final double screenHeight = game.size.y; // alto de la pantalla


    position.y = clampDouble(
      position.y,
      size.y / 2,
      screenHeight - size.y / 2,
    );


    if (position.x < 0) {
      position.x = screenWidth;
    } else if (position.x > screenWidth) {
      position.x = 0;
    }

  }
}