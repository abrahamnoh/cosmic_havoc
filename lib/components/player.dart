import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/bomb.dart';
import 'package:cosmic_havoc/components/explosion.dart';
import 'package:cosmic_havoc/components/laser.dart';
import 'package:cosmic_havoc/components/pickup.dart';
import 'package:cosmic_havoc/components/powerup.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';


class Player extends SpriteAnimationComponent 
    with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks {
  bool _isShooting = false;
  final double _fireCooldown = 0.2; // tiempo entre disparos en segundos
  double _elapsedFireTime = 0.0; // este es para llevar el tiempo transcurrido desde el último disparo
  final Vector2 _keyboardMovenment = Vector2.zero(); //esto es para el movimiento con teclado y que se inicializa en cero
  bool _isDestroyed = false;
  final Random _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  Powerup? activePowerup;

  Player(){
    _explosionTimer = Timer(
      0.1,
      onTick: _createRandomExplosion,
      repeat: true,
      autoStart: false,
    );

    _laserPowerupTimer = Timer(
      10.0,
      autoStart: false,
    );
  }


  @override
  FutureOr<void> onLoad() async{
   animation = await _loadPlayerAnimation();


    size *= 0.3; //esto es para reducir el tamaño del jugador

    add(RectangleHitbox.relative(
      Vector2(0.6, 0.9),
      parentSize: size,
      anchor: Anchor.center,
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
        super.update(dt);

        if (_isDestroyed) {
          _explosionTimer.update(dt);
          return;
        }

    if (_laserPowerupTimer.isRunning()) {
      _laserPowerupTimer.update(dt);
    }


    // combine the joystick input with the keyboard movement y en español: combina la entrada del joystick con el movimiento del teclado
    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovenment;
    position += movement.normalized() * 200 * dt;

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

  Future<SpriteAnimation> _loadPlayerAnimation() async {
    return SpriteAnimation.spriteList(
      [
        await game.loadSprite('player_blue_on0.png'),
        await game.loadSprite('player_blue_on1.png'),
      ], 
    stepTime: 0.1,
    loop: true,
    );
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

    if(_laserPowerupTimer.isRunning()){
      game.add(
        Laser(position: position.clone() + Vector2(0, -size.y / 2),
        angle: 15 * degrees2Radians),
      );

      game.add(
        Laser(position: position.clone() + Vector2(0, -size.y / 2),
        angle: -15 * degrees2Radians),
      );
    }


  }

  void _handleDestruction() async{
    animation = SpriteAnimation.spriteList(
      [
        await game.loadSprite('player_blue_off.png'),
      ],
      stepTime: double.infinity,
    );

    add(ColorEffect(
      const Color.fromRGBO(255, 255, 255, 1.0),
      EffectController(duration: 0.0),
    ));

    add(OpacityEffect.fadeOut(//esto lo agregamos para que el jugador desaparezca lentamente después de ser destruido y que el efecto dure 3 segundos
      EffectController(duration: 3.0),
      onComplete: () => _explosionTimer.stop(),

    ));

    add(MoveEffect.by(
      Vector2(0, 200),
      EffectController(duration: 3.0),
    ));

    add(RemoveEffect(delay: 4.0));//esto es para eliminar el jugador después de 4 segundos
    
    _isDestroyed = true;

    _explosionTimer.start();

  }

  void _createRandomExplosion(){
    final Vector2 explosionPosition = Vector2(
      position.x - size.x / 2 + _random.nextDouble() * size.x,
      position.y - size.y / 2 + _random.nextDouble() * size.y,
    );

    final ExplosionType explosionType =
        _random.nextBool() ? ExplosionType.smoke : ExplosionType.fire;

    final Explosion explosion = Explosion(
      position: explosionPosition,
      explosionSize: size.x * 0.3,
      explosionType: explosionType,
    );

    game.add(explosion);
  }



  @override // esto es para manejar las colisiones del jugador con los asteroides y cuando ocurre una colisión se llama a la función _handleDestruction que maneja la destrucción del jugador.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (_isDestroyed) return;

    if (other is Asteroid){

      if (activePowerup == null)_handleDestruction();
    } else if (other is Pickup){
      other.removeFromParent();
      game.incrementScore(1);

      switch (other.pickupType){
        case PickupType.laser:
          _laserPowerupTimer.start();
          break;
        case PickupType.bomb:
        game.add(Bomb(position: position.clone())); 
          // Implement bomb pickup effect here
          break;
        case PickupType.powerup:
          if (activePowerup != null) {
            activePowerup!.removeFromParent();
          }
          activePowerup = Powerup();
          add(activePowerup!);
          break;
      }
      // Ignorar colisiones con los pickups
    }
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