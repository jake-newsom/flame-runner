import 'dart:ui';
import 'dart:math';

import 'package:kcm_app/floor.dart';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/layers.dart';

class MyGame extends BaseGame with DoubleTapDetector {
  Random rng;
  SpriteComponent ninja = SpriteComponent();

  Layer backgroundLayer;
  List<Floor> floors;

  bool running = true;
  bool jumping = false;
  String direction = "down";

  @override
  Future<void> onLoad() async {
    initialize();

    print('loading assets');
    ninja
      ..sprite = await loadSprite("ninja.png")
      ..size = Vector2(100.0, 100.0)
      ..x = 60
      ..y = this.size.y - ninja.size.y;
    add(ninja);

    for (var i = 0; i < 3; i++) {
      createNewFloor();
    }
  }

  void initialize() {
    this.floors = [];
    this.rng = new Random();
  }

  // @override
  // render(Canvas canvas) {
  //   backgroundLayer.render(canvas);
  // }

  @override
  update(double dt) {
    super.update(dt);

    updateFloors();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // this.backgroundLayer.render(canvas);
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
    print("jump bitch");
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
    }

    Floor floor = Floor()
      ..x = startX.toDouble()
      ..y = this.size.y
      ..height = 20
      ..width = this.rng.nextInt(screenWidth).toDouble() + minWidth;

    this.floors.add(floor);
    add(floor);
  }
}

class BackgroundLayer extends PreRenderedLayer {
  // final Sprite sprite;

  BackgroundLayer() {
    // preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() {
    // sprite.render(
    //   canvas,
    //   position: Vector2(50, 200),
    //   size: Vector2(300, 150),
    // );
    var rect = new Rect.fromLTWH(0.0, 0.0, 600.0, 600.0);
    var paint = new Paint()..color = new Color(0xFFFFffff);
    canvas.drawRect(rect, paint);
  }
}
