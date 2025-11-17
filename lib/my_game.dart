import 'dart:async';
import 'package:cosmic_havoc/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart'; //este paquete sirve para configurar el juego y el dispositivo
import 'package:flame/game.dart';

class MyGame extends FlameGame {
  late Player player;
  late JoystickComponent joystick;

  @override
  FutureOr<void> onLoad() async {
     
    await Flame.device.fullScreen();//esto es para que el juego ocupe toda la pantalla y no se vean barras negras
    await Flame.device.setPortrait();// esto es para que el juego se vea en modo vertical
    startGame();

    return super.onLoad();
  }

  void startGame() async{
    await _createJoystick();
    _createPlayer();

  }
  void _createPlayer(){
    player = Player()
    ..anchor = Anchor.center
    ..position = Vector2(size.x /2, size.y * 0.8);
    add(player);
  }


  Future<void> _createJoystick() async {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: await loadSprite('joystick_knob.png'),
      size: Vector2.all(50),),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(20, size.y - 20), //esto es para posicionar el joystick en la esquina inferior izquierda y dejar un margen de 20 pixels
      priority: 10,
    );
    add(joystick);
      
  }
}