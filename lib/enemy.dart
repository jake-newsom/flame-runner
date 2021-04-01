import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:kcm_app/game.dart';
import 'package:kcm_app/entity.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Enemy extends SpriteComponent with Hitbox, Collidable {
  MyGame game;
  bool killable;

  static List<Vector2> SOLDIER = [
    Vector2(-1, -1),
    Vector2(0, -1),
    Vector2(0.3, .5),
    Vector2(.7, .5),
    Vector2(.7, 1),
    Vector2(-1, 1)
  ];

  static List<Vector2> SPIKES = [
    Vector2(-1, -1),
    Vector2(1, -1),
    Vector2(1, 1),
    Vector2(-1, 1)
  ];

  Enemy(parent, killable) {
    this.anchor = Anchor.bottomLeft;
    this.game = parent;
    this.killable = killable;
  }

  void setHitbox(List<Vector2> definition) {
    var hitbox = new HitboxPolygon(definition);
    addShape(hitbox);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    this.renderShapes(c);
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
    this.game.enemies.removeAt(0);
    this.remove();
  }
}
