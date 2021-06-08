import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:kcm_app/game.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Entity extends SpriteComponent with Hitbox, Collidable {
  late MyGame game;
  late HitboxRectangle hitbox;

  Entity(parent) {
    this.game = parent;

    this.hitbox = HitboxRectangle();
    this.addShape(this.hitbox);
  }

  @override
  void render(Canvas c) {
    super.render(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    this.x -= this.game.speed;
    if (this.x + this.width < 0) {
      this.die();
    }
  }

  @override
  void onMount() {
    super.onMount();
  }

  void die() {
    this.remove();
  }
}
