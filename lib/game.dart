import 'dart:ui';
import 'dart:math';

// import 'package:kcm_app/floor.dart';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/layers.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class MyGame extends BaseGame with DoubleTapDetector {
  Random rng;
  SpriteComponent playerSprite = SpriteComponent();

  Layer backgroundLayer;
  Layer gameLayer;
  List<Floor> floors;

  bool running = false;

  @override
  Future<void> onLoad() async {
    initializeGraphics();
    initializeVariables();
  }

  void initializeVariables() {
    this.floors = [];
    this.rng = new Random();
  }

  void initializeGraphics() async {
    /** initialize background */
    final backgroundSprite = Sprite(await images.load('background.png'));
    this.backgroundLayer = BackgroundLayer(backgroundSprite);

    /** player sprite */
    this.playerSprite
      ..sprite = await loadSprite("ninja.png")
      ..size = Vector2(100.0, 100.0)
      ..x = 60
      ..y = this.size.y - this.playerSprite.size.y - 20;

    add(this.playerSprite);
    for (var i = 0; i < 3; i++) {
      this.createNewFloor();
    }
    this.running = true;
  }

  @override
  update(double dt) {
    super.update(dt);
    if (this.running) {
      updateFloors();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    try {
      // this.backgroundLayer.render(canvas);

      // this.playerSprite.render(canvas);

      // for (var floor in this.floors) {
      //   floor.render(canvas);
      // }
    } catch (e) {}
  }

  @override
  Color backgroundColor() => const Color(0xFF38607C);

  @override
  void onDoubleTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }
    running = !running;
  }

  void updateFloors() {
    for (var floor in floors) {
      floor.x -= 5;
      if (floor.x + floor.width < 0) {
        floors.remove(floor);
        createNewFloor();
      }
    }
  }

  void createNewFloor() {
    var screenWidth = (this.size.x).round();
    var minWidth = screenWidth / 2;

    var gap = this.rng.nextInt((screenWidth / 2).round()) + (screenWidth / 10);

    var startX = 0;
    if (this.floors.length > 0) {
      startX += (this.floors.last.x + this.floors.last.width + gap).round();
    }

    print(this.size.y - 20);
    Floor floor = Floor()
      ..anchor = Anchor.topLeft
      ..x = startX.toDouble()
      ..y = this.size.y - 20
      ..height = 20
      ..width = this.rng.nextInt(screenWidth).toDouble() + minWidth;

    this.floors.add(floor);
    this.add(floor);
  }
}

class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite);

  @override
  void drawLayer() {
    sprite.render(canvas, position: Vector2(0, 0));
  }
}

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
