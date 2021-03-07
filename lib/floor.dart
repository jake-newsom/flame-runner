import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Floor extends SpriteComponent {
  String name;

  @override
  void render(Canvas c) {
    // super.render(c);
    c.drawRect(this.toRect(), BasicPalette.white.paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onMount() {
    super.onMount();
  }
}
