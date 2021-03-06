import 'dart:ui';
import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:kcm_app/entity.dart';
import 'package:kcm_app/player.dart';
import 'package:kcm_app/enemy.dart';
import 'package:kcm_app/tree.dart';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame/layers.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

import 'package:sensors_plus/sensors_plus.dart';

class MyGame extends BaseGame with TapDetector, HasCollidables {
  late Random rng;

  // final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));

  /** Sprites */
  late Background backgroundSprite;
  // SpriteComponent backgroundSprite = SpriteComponent();
  SpriteComponent playerSprite = SpriteComponent();
  Sprite? enemySprite;
  Sprite? spikesSprite;
  Sprite? treeSprite;

  late Player player;

  Layer? backgroundLayer;
  Layer? gameLayer;
  List<Entity>? floors;
  late List<Enemy?> enemies;
  late List<Ground> grounds;

  late double gravity;
  late double speed;
  late double maxSpeed;

  /** platform config */
  late double baseMinWidth;
  late double currentMinWidth;

  bool debug = true;

  /** game variables */
  Timer? interval;
  late int elapsedSecs;
  bool running = true;

  double inputThreshold = 0.7;

  @override
  Future<void> onLoad() async {
    initializeGraphics();
    initializeVariables();
    this.startGame();
  }

  void initializeVariables() {
    this.enemies = [];
    this.rng = new Random();
  }

  void initializeGraphics() async {
    this.enemySprite = await loadSprite('enemy.png');
    this.spikesSprite = await loadSprite('spikes.png');

    /** initialize background */
    this.backgroundSprite =
        new Background(await loadSprite("Background-4.png"), this);
    add(this.backgroundSprite);

    add(new Background(await loadSprite("Background-3.png"), this));
    add(new Background(await loadSprite("Background-2.png"), this));

    await images.load("tree-spritesheet.png");
    await images.load("rock.png");

    this.grounds = [];
    for (var i = 0; i < 4; i++) {
      Ground g = new Ground(await loadSprite("ground.png"), this, i);
      this.grounds.add(g);
      add(g);
    }

    final playerSpriteSheet = SpriteSheet(
      image: await images.load('warrior.png'),
      srcSize: Vector2.all(48.0),
    );

    this.player = new Player(this, playerSpriteSheet)
      ..anchor = Anchor.bottomRight
      ..size = Vector2(100.0, 100.0)
      ..x = 160
      ..y = this.size.y - 30;

    add(this.player);
  }

  @override
  update(double dt) {
    if (this.running) {
      super.update(dt);
      if (interval != null) {
        interval!.update(dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // textConfig.render(canvas, "Elapsed time: $elapsedSecs", Vector2(10, 10));
  }

  @override
  Color backgroundColor() => const Color(0xFF38607C);

  @override
  void onTapDown(TapDownInfo tap) {
    if (this.running) {
      // if (tap.raw.globalPosition.dx < this.size.x ~/ 2) {
      //   this.player.jump();
      // } else {
      //   this.player.attack();
      // }
    } else {
      this.startGame();
    }
  }

  void startGame() {
    this.enemies = [];

    this.gravity = 1.5;
    this.speed = 6.0;
    this.maxSpeed = 25;

    /** platform config */
    this.baseMinWidth = 140;
    this.currentMinWidth = 300;

    this.elapsedSecs = 0;

    this.interval = Timer(
      1,
      callback: this.gameTick,
      repeat: true,
    );
    this.interval!.start();
    this.running = true;
    this.listenForInput();
  }

  void endGame() {
    this.interval!.stop();
    this.running = false;

    for (var enemy in this.enemies) {
      enemy!.remove();
    }
  }

  void gameTick() {
    this.increaseDifficulty();
    this.spawnObstacles();
    this.elapsedSecs += 1;

    this.generateEnvironment();
  }

  void increaseDifficulty() {
    /** bump up difficulty */
    if (this.speed < this.maxSpeed) {
      this.speed += 0.05;
    }

    if (this.currentMinWidth > this.baseMinWidth) {
      this.currentMinWidth -= 1;
    }
  }

  void spawnObstacles() {
    var i = this.rng.nextInt(100);

    /** spawn enemy with random chance */
    if (i > 80) {
      this.createEnemy();
    } else if (i > 60) {
      this.createTrap();
    }
  }

  void createEnemy() {
    var enemyType = this.rng.nextInt(2);

    Enemy? baddie;
    if (enemyType == 0) {
      baddie = Enemy(this, true)
        ..sprite = this.enemySprite
        ..size = Vector2(60.0, 60.0)
        ..x = this.size.x
        ..y = this.size.y - 20;
      baddie.setHitbox(Enemy.SOLDIER);
    } else if (enemyType == 1) {
      baddie = Enemy(this, false)
        ..sprite = this.enemySprite
        ..size = Vector2(100.0, 100.0)
        ..x = this.size.x
        ..y = this.size.y - 20;
      baddie.setHitbox(Enemy.SOLDIER);
    }
    this.enemies.add(baddie);
    this.add(baddie!);
  }

  void createTrap() {
    Enemy trap = Enemy(this, false)
      ..sprite = this.spikesSprite
      ..size = Vector2(100.0, 30.0)
      ..x = this.size.x
      ..y = this.size.y - 10;

    trap.setHitbox(Enemy.SPIKES);
    this.enemies.add(trap);
    this.add(trap);
  }

  void generateEnvironment() {
    var frontLayer = this.rng.nextInt(10);
    if (frontLayer > 5) {
      this.add(new Tree(this, 1, 1.0));
    }

    var midLayer = this.rng.nextInt(10);
    if (midLayer > 5) {
      this.add(new Tree(this, 2, 0.5));
    }

    var backLayer = this.rng.nextInt(10);
    if (backLayer > 5) {
      this.add(new Tree(this, 3, 0.25));
    }
  }

  void createPowerUp() {}

  void listenForInput() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // print(event);
    });

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      // print(event);
      // if (event.x < -2.5) {
      //   print("Jump 1");
      // }
      // if (event.z > this.inputThreshold) {
      //   print("jump 2");
      //   this.player.jump();
      // }
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      // print(event);

      if (event.x > this.inputThreshold) {
        this.player.attack();
      } else if (event.x < -this.inputThreshold) {
        this.player.slide();
      } else if (event.y < -this.inputThreshold) {
        this.player.jump();
      }
    });
  }
}

class Background extends SpriteComponent {
  final priority = -10;

  Background(sprite, game) {
    this.sprite = sprite;
    this.size = Vector2(game.size.x, game.size.y);
    this.x = 0;
    this.y = 0;
  }
}

class Ground extends SpriteComponent {
  final priority = -1;
  late int count;
  late MyGame game;

  Ground(sprite, game, count) {
    this.anchor = Anchor.topLeft;
    this.count = count;
    this.game = game;
    this.sprite = sprite;
    this.x = (game.size.x * 0.75) * count;
    this.y = game.size.y - 80;
    this.size = Vector2(game.size.x * 0.75, 100);
  }

  @override
  void update(double dt) {
    super.update(dt);

    this.x -= this.game.speed;

    // clear tree once it's off screen
    if (this.x + this.width < 0) {
      this.reset();
    }
  }

  void reset() {
    var last = this.count - 1;
    if (last < 0) {
      last = 3;
    }

    this.x = this.game.grounds[last].x + this.game.grounds[last].width - 10;
  }
}
