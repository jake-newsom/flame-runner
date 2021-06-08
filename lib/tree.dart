import 'dart:math';
import 'dart:ui';

import 'package:kcm_app/game.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

class Tree extends SpriteComponent {
  MyGame? game;
  int priority = -1;
  late double speedRatio;

  Paint? overlay;

  final int MINWIDTH = 60;
  final int MAXWIDTH = 240;

  Tree(parent, layer, speedRatio) {
    this.game = parent;
    this.speedRatio = speedRatio;
    this.priority = layer * -1;

    // setup tree graphics

    if (this.priority < -1) {
      int alpha = 30;
      if (this.priority < -2) {
        alpha = 80;
      }

      double blur = (1.2 * layer).toDouble();
      this.overlay = new Paint()
        ..colorFilter = ColorFilter.mode(
            Color.fromARGB(alpha, 255, 255, 255), BlendMode.srcATop);
      // ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    }

    this.anchor = Anchor.bottomLeft;
    this.generateTree();
    this.generateStones();
  }

  @override
  void render(Canvas c) {
    super.render(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    this.x -= this.game!.speed * this.speedRatio;

    // clear tree once it's off screen
    if (this.x + (this.width * 4) < 0) {
      this.remove();
    }
  }

  @override
  void onMount() {
    super.onMount();
  }

  void generateTree() {
    var numberOfBranches = game!.rng.nextInt(3) + 1;
    var trunkWidth =
        game!.rng.nextInt(this.MAXWIDTH - (this.priority * -15)) + this.MINWIDTH;

    this.size = Vector2(trunkWidth.toDouble(), this.game!.size.y);
    this.x = this.game!.size.x + (this.width * 1.5);
    this.y = this.game!.size.y - 50;
    if (this.priority < -1) {
      this.y += 20;
    }

    for (var i = 0; i < numberOfBranches; i++) {
      Branch branch = new Branch(this);

      if (this.priority < -1) {
        // int alpha = (this.priority * 20).abs();
        // branch.overridePaint.colorFilter = ColorFilter.mode(
        //     Color.fromARGB(alpha, 0, 0, 0), BlendMode.srcATop);
        // branch.overridePaint.imageFilter =
        //     ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0);
        branch.overridePaint = this.overlay;
        this.angle = ((this.game!.rng.nextDouble() * 0.04) - 0.02) * pi;
      }

      this.addChild(branch, gameRef: this.game);
    }

    this.addChild(
        new SpriteComponent(
            position: Vector2(0.0, 0.0),
            size: Vector2(this.size.x, this.size.y),
            sprite: this.sprite = Sprite(
                this.game!.images.fromCache("tree-spritesheet.png"),
                srcPosition: Vector2(0.0, 0.0),
                srcSize: Vector2(321.0, 1009.0)),
            overridePaint: this.overlay),
        gameRef: this.game);

    //background effects
    this.overridePaint = this.overlay;
  }

  void generateStones() {
    var numberofStones = game!.rng.nextInt(3);
    for (var i = 0; i < numberofStones; i++) {
      Stone stone = new Stone(this);
      if (this.priority < -1) {
        stone.overridePaint = this.overlay;
      }
      this.addChild(stone, gameRef: this.game);
    }
  }
}

class Stone extends SpriteComponent {
  int priority = 1;
  late Tree tree;

  Stone(tree) {
    this.tree = tree;

    this.anchor = Anchor.bottomCenter;
    this.sprite = new Sprite(this.tree.game!.images.fromCache("rock.png"),
        srcPosition: Vector2(0.0, 0.0));
    this.position = Vector2(
        nextInt(this.tree.width.round()).toDouble(), this.tree.height + 8);

    this.size = Vector2(200.0, 60.0);
  }

  int nextInt(int max) {
    return this.tree.game!.rng.nextInt(max);
  }
}

class Branch extends SpriteComponent {
  int priority = -6;
  late Tree tree;

  late int variation;
  int? side;
  late double horizontalOffset;
  late double yPos;

  List<List<Map>> branches = [
    [
      {"position": Vector2(384.0, 0.0), "size": Vector2(94.0, 219.0)},
      {"position": Vector2(403.0, 252.0), "size": Vector2(77.0, 167.0)},
      {"position": Vector2(352.0, 428.0), "size": Vector2(128.0, 124.0)},
      {"position": Vector2(391.0, 561.0), "size": Vector2(89.0, 174.0)},
      {"position": Vector2(364.0, 754.0), "size": Vector2(114.0, 255.0)},
    ],
    [
      {"position": Vector2(480.0, 0.0), "size": Vector2(94.0, 219.0)},
      {"position": Vector2(480.0, 252.0), "size": Vector2(77.0, 167.0)},
      {"position": Vector2(480.0, 428.0), "size": Vector2(128.0, 124.0)},
      {"position": Vector2(480.0, 561.0), "size": Vector2(89.0, 174.0)},
      {"position": Vector2(480.0, 754.0), "size": Vector2(114.0, 255.0)},
    ]
  ];

  Branch(tree) {
    this.tree = tree;
    this.randomize();

    this.anchor = Anchor.bottomRight;
    this.sprite = new Sprite(
        this.tree.game!.images.fromCache("tree-spritesheet.png"),
        srcPosition: this.branches[this.side!][this.variation]["position"],
        srcSize: this.branches[this.side!][this.variation]["size"]);
    this.position = Vector2(this.tree.width * this.horizontalOffset, this.yPos);

    if (this.side == 1) {
      this.anchor = Anchor.bottomLeft;
      this.position.x = this.tree.width * (1.05 - this.horizontalOffset);
    }

    this.overridePaint = new Paint();
  }

  void randomize() {
    this.variation = nextInt(this.branches.length);
    this.side = nextInt(2);
    this.horizontalOffset = 0.38;

    Vector2 branchSize = this.branches[side!][this.variation]["size"];
    int branchWidth = nextInt(branchSize.x.toInt()) + 60;
    int branchHeight = nextInt(branchSize.y.toInt()) + 60;
    this.size = Vector2(branchWidth.toDouble(), branchHeight.toDouble());

    this.yPos = (nextInt((this.tree.height * 0.6).toInt()) + 60).toDouble();
    double diff = (this.yPos / (this.tree.height * 0.6)) * 0.05;
    this.horizontalOffset -= diff;

    return;
  }

  int nextInt(int max) {
    return this.tree.game!.rng.nextInt(max);
  }
}
