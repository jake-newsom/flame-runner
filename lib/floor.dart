import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Floors {
  List<Floor> floors;
}

class Floor extends PositionComponent {
  static const speed = 0.25;
  static const squareSize = 128.0;

  @override
  void render(Canvas c) {
    super.render(c);

    c.drawRect(size.toRect(), BasicPalette.white.paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onMount() {
    super.onMount();
    // size = Vector2.all(squareSize);
    anchor = Anchor.center;
  }
}
