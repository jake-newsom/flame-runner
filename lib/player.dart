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
import 'package:flame/sprite.dart';

class Player extends SpriteAnimationComponent with Hitbox, Collidable {
  int? state;
  String? name;
  late MyGame game;
  bool? jumping;
  late bool onFloor;

  late bool attacking;
  late Timer attackTimer;

  late Timer stateTimer;

  static int RUNNING = 1;
  static int JUMPING = 2;
  static int SLIDING = 3;
  static int ATTACKING = 4;

  double ySpeed = 0;

  late SpriteSheet spritesheet;
  late Map<String, SpriteAnimation> animations;

  Player(game, spritesheet) {
    this.game = game;
    this.state = Player.RUNNING;
    this.onFloor = false;
    this.jumping = false;
    this.attacking = false;
    this.spritesheet = spritesheet;

    final shape = HitboxPolygon([
      Vector2(0, 0),
      Vector2(0.5, 0.2),
      Vector2(0.6, 1),
      Vector2(-0.6, 1),
      Vector2(-0.5, 0.2)
    ]);
    addShape(shape);

    this.stateTimer = new Timer(0);

    this.animations = new Map();
    this.animations["run"] =
        this.spritesheet.createAnimation(row: 0, stepTime: 0.1);
    this.animations["jump"] = this
        .spritesheet
        .createAnimation(row: 2, stepTime: 0.1, loop: false, from: 0, to: 6);
    this.animations["slide"] = this
        .spritesheet
        .createAnimation(row: 1, stepTime: 0.1, loop: false, from: 0, to: 4);
    this.animations["attack"] = this
        .spritesheet
        .createAnimation(row: 3, stepTime: 0.1, loop: false, from: 0, to: 6);

    this.animation = this.animations["run"];
  }

  void resetState() {
    this.animation = this.animations["run"];
    this.attacking = false;
    this.state = Player.RUNNING;
  }

  void startStateTimer(double timerLength) {
    this.stateTimer = Timer(
      timerLength,
      callback: this.resetState,
      repeat: false,
    );
    this.stateTimer.start();
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
      if (this.jumping == true) {
        this.animation = this.animations["run"];
        this.animations["jump"]!.reset();
      }
      this.jumping = false;
    }

    /** Progress timer if it's active */
    if (this.stateTimer != null && this.stateTimer.isRunning()) {
      this.stateTimer.update(dt);
    }
    // if (this.attacking) {
    //   this.attackTimer.update(dt);
    // }
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
    if (this.ySpeed == 0 && this.state != Player.ATTACKING) {
      this.ySpeed = -25;
      this.jumping = true;
      this.onFloor = false;
      this.animation = this.animations["jump"];
    }
  }

  void slide() {
    if (this.state == Player.RUNNING) {
      this.state = Player.SLIDING;
      this.animations["slide"]!.reset();
      this.animation = this.animations["slide"];
      this.startStateTimer(0.6);
    }
  }

  void attack() {
    if (this.state == Player.RUNNING) {
      this.state = Player.ATTACKING;
      this.attacking = true;
      this.animations["attack"]!.reset();
      this.animation = this.animations["attack"];
      this.startStateTimer(0.5);
    }
  }

  void checkFloors() {
    bool grounded = false;

    if (this.y > this.game.size.y - 35) {
      this.y = this.game.size.y - 35;
      grounded = true;
    }
    this.onFloor = grounded;
  }
}
