import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:kcm_app/enemy.dart';
import 'package:kcm_app/game.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/timer.dart';

class Player extends SpriteAnimationComponent with Hitbox, Collidable {
  String name;
  MyGame game;
  bool jumping;
  bool onFloor;

  bool attacking;
  Timer attackTimer;

  double ySpeed = 0;

  Player(game) {
    this.game = game;
    this.onFloor = false;
    this.jumping = false;
    this.attacking = false;

    final shape = HitboxPolygon([
      Vector2(0, 0),
      Vector2(0.5, 0.2),
      Vector2(0.6, 1),
      Vector2(-0.6, 1),
      Vector2(-0.5, 0.2)
    ]);
    addShape(shape);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    this.renderShapes(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!this.onFloor) {
      this.ySpeed += this.game.gravity;
      if (this.ySpeed > 15) {
        this.ySpeed = 15;
      }
    }
    this.y += this.ySpeed;

    /** check if I'm on a floor */
    this.checkFloors();
    if (this.onFloor) {
      this.ySpeed = 0;
      this.jumping = false;
    }

    if (this.attacking) {
      print("update timer");
      this.attackTimer.update(dt);
    }
  }

  @override
  void onMount() {
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Enemy) {
      print("Is attacking? " + this.attacking.toString());
      if (this.attacking && other.killable) {
        other.die();
      } else {
        this.game.endGame();
      }
    }
  }

  void jump() {
    if (this.ySpeed == 0) {
      this.ySpeed = -25;
      this.jumping = true;
      this.onFloor = false;
    }
  }

  void attack() {
    this.attacking = true;
    this.attackTimer = Timer(
      1,
      callback: this.stopAttacking,
      repeat: false,
    );
    this.attackTimer.start();
  }

  void stopAttacking() {
    print("Stop attacking!");
    this.attacking = false;
  }

  void checkFloors() {
    bool grounded = false;

    if (this.y > this.game.size.y - 20) {
      this.y = this.game.size.y - 20;
      grounded = true;
    }
    this.onFloor = grounded;
  }
}
