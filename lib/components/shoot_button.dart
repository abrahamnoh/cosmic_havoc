import 'dart:async';

import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class ShootButton extends SpriteComponent with HasGameReference<MyGame>, TapCallbacks {
  ShootButton() : super(size : Vector2.all(80));

  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite('shoot_button.png');

    return super.onLoad();
  }
  @override
  void onTapDown(TapDownEvent event) {
    
    super.onTapDown(event);

    game.player.startShooting();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    game.player.stopShooting();
  }

  @override
  void onTapCancel(TapCancelEvent event) {//esto lo agregamos para que si el jugador mueve el dedo fuera del boton deje de disparar
    super.onTapCancel(event);
    game.player.stopShooting();
  }
}