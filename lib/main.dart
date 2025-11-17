import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final MyGame game = MyGame();

  runApp(GameWidget(game: game));
}


