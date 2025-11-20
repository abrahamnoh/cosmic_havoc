import 'dart:async';
import 'dart:ui';

import 'package:cosmic_havoc/components/laser.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';


class Player extends SpriteComponent with HasGameReference<MyGame>, KeyboardHandler{
  bool _isShooting = false;
  final double _fireCooldown = 0.2; // tiempo entre disparos en segundos
  double _elapsedFireTime = 0.0; // este es para llevar el tiempo transcurrido desde el último disparo
  final Vector2 _keyboardMovenment = Vector2.zero(); //esto es para el movimiento con teclado y que se inicializa en cero
  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite('player_blue_on0.png'); 


    size *= 0.3; //esto es para reducir el tamaño del jugador

    return super.onLoad();
  }

  @override
  void update(double dt) {
        super.update(dt);
    // combine the joystick input with the keyboard movement y en español: combina la entrada del joystick con el movimiento del teclado
    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovenment;


    // Movimiento del jugador basado en el joystick
    position += movement.normalized() * 200 * dt; // esto es para mover el jugador a una velocidad de 200 pixels por segundo


    _handleScreenBounds(); //esto es para que el jugador no se salga de la pantalla, es una funcion 

    // Manejo del disparo continuo
    _elapsedFireTime += dt;

    if (_isShooting && _elapsedFireTime >= _fireCooldown){ // este es para manejar el disparo continuo
      _fireLaser();
      _elapsedFireTime = 0.0;
    }
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

  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireLaser() {
    game.add(
      Laser(position: position.clone() + Vector2(0, -size.y / 2)),
    );
  }


//esto es para manejar el movimiento con teclado y para una deescripcion mas detallada seria: que esta funcion se llama cada vez que se presiona una tecla y recibe un evento de tecla y un conjunto de teclas presionadas.
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardMovenment.x = 0;
    _keyboardMovenment.x +=
        (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0);
    _keyboardMovenment.x +=
        (keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0);

    _keyboardMovenment.y = 0;
    _keyboardMovenment.y +=
        (keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0);
    _keyboardMovenment.y +=
        (keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0);    
    return true;
  }

}