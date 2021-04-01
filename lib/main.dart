import 'package:flame/flame.dart';
import 'package:kcm_app/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.setLandscape();

  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}
