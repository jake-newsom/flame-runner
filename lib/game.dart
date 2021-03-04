import 'dart:ui';
import 'dart:math';

import 'package:kcm_app/floor.dart';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/layers.dart';

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

    for (var i = 0; i < 3; i++) {
      createNewFloor();
    }
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
      ..y = this.size.y - this.playerSprite.size.y;

    this.gameLayer = GameLayer(this);
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
      this.backgroundLayer.render(canvas);
      this.gameLayer.render(canvas);
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
      if (0 > (floor.x + floor.width)) {
        floors.remove(floor);
        createNewFloor();
      }
    }
  }

  void createNewFloor() {
    print("create a new floor");

    var screenWidth = this.size.x.round();
    var minWidth = screenWidth / 2;

    var gap = this.rng.nextInt((screenWidth / 3).round()) + (screenWidth / 10);

    var startX = 0;
    if (this.floors.length > 0) {
      startX += (this.floors.last.x + this.floors.last.width + gap).round();
      print(startX.toString());
    }

    Floor floor = Floor()
      ..x = startX.toDouble()
      ..y = this.size.y - 20
      ..height = 20
      ..width = this.rng.nextInt(screenWidth).toDouble() + minWidth
      ..anchor = Anchor.topLeft;

    this.floors.add(floor);
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

class GameLayer extends DynamicLayer {
  final MyGame game;

  GameLayer(this.game);

  @override
  void drawLayer() {
    // draw player
    game.playerSprite.sprite.render(canvas,
        position: Vector2(game.playerSprite.x, game.playerSprite.y));

    for (var i = 0; i < game.floors.length; i++) {
      var floor = game.floors[i];
      floor.render(canvas);
    }
  }
}
