import 'dart:async';
import 'dart:math';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';

class Asteroid extends SpriteComponent with HasGameReference<MyGame> {
   final Random _random = Random();
   static const double _maxSize = 120;
   late Vector2 _velocity;
   late double _spinSpeed;
   
   Asteroid({required super.position, double size = _maxSize}) 
   : super(
    size: Vector2.all(size), 
    anchor: Anchor.center,
   priority: -1,
   
   ){
    _velocity = _generateVelocity();
    _spinSpeed = _random.nextDouble() * 1.5 - 0.75;
   }

   @override
  FutureOr<void> onLoad() async{
    final int imageNum = _random.nextInt(3) + 1; // Genera un número aleatorio entre 1 y 3
    sprite = await game.loadSprite('asteroid$imageNum.png');
    
    return super.onLoad();
  }


  @override
  void update(double dt) {
    position += _velocity * dt;

    _handleScreenBounds();
    
    angle += _spinSpeed * dt;
    
    super.update(dt);
  }

  Vector2 _generateVelocity() {
    final double forceFactor = _maxSize / size.x; // Ajusta la velocidad según el tamaño del asteroide
    return Vector2(
    _random.nextDouble() * 120 - 60,
    100 + _random.nextDouble() * 50,
    ) * 
    forceFactor;

  }
  void _handleScreenBounds(){

    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }

    final double screenWidth = game.size.x;
    if (position.x < -size.x){
      position.x = screenWidth + size.x / 2;
    }
    else if (position.x > screenWidth + size.x){
      position.x = -size.x / 2;
    }
  }
 
}