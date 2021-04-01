import 'dart:ui';

import 'package:kcm_app/game.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

class Tree extends SpriteComponent {
  MyGame game;
  final priority = -1;

  List<Map> branches = [
    {"position": Vector2(384.0, 0.0), "size": Vector2(96.0, 219.0)},
    {"position": Vector2(403.0, 252.0), "size": Vector2(77.0, 167.0)},
    {"position": Vector2(352.0, 428.0), "size": Vector2(128.0, 124.0)},
    {"position": Vector2(391.0, 561.0), "size": Vector2(89.0, 176.0)},
    {"position": Vector2(366.0, 754.0), "size": Vector2(114.0, 255.0)},
  ];

  Tree(parent) {
    this.anchor = Anchor.bottomLeft;
    this.game = parent;

    // setup tree graphics
    this.sprite = Sprite(this.game.images.fromCache("tree-spritesheet.png"),
        // srcPosition: Vector2(310.0, 0.0), srcSize: Vector2(170.0, 300.0));
        srcPosition: Vector2(0.0, 0.0),
        srcSize: Vector2(310.0, 1000.0));

    this.generateTree();

    // this.x = this.game.rng.nextInt(this.game.size.x.round()).toDouble();
    // this.y = 0;
    // this.size = Vector2(50.0, this.game.size.y);
  }

  @override
  void render(Canvas c) {
    super.render(c);
  }

  @override
  void update(double dt) {
    super.update(dt);

    this.x -= this.game.speed;

    // clear tree once it's off screen
    if (this.x + (this.width * 1.5) < 0) {
      this.remove();
    }
  }

  @override
  void onMount() {
    super.onMount();
  }

  void generateTree() {
    var numberOfBranches = game.rng.nextInt(5) + 1;
    var trunkWidth = game.rng.nextInt(140) + 30;

    this.size = Vector2(trunkWidth.toDouble(), this.game.size.y);
    this.x = this.game.size.x + (this.width * 1.5);
    this.y = this.game.size.y - 20;

    for (var i = 0; i < numberOfBranches; i++) {
      var branchSprite = game.rng.nextInt(this.branches.length);
      var side = game.rng.nextInt(2);

      Vector2 branchSize = this.branches[branchSprite]["size"];
      var branchWidth = game.rng.nextInt(branchSize.x.toInt()) + 60;
      var branchHeight = game.rng.nextInt(branchSize.y.toInt()) + 60;

      var branch = new SpriteComponent()
        ..anchor = Anchor.bottomRight
        ..position = Vector2((this.width * 0.38),
            (game.rng.nextInt((this.height * 0.8).toInt()) + 60).toDouble())
        ..size = Vector2(branchWidth.toDouble(), branchHeight.toDouble())
        ..sprite = new Sprite(
            this.game.images.fromCache("tree-spritesheet.png"),
            srcPosition: this.branches[branchSprite]["position"],
            srcSize: branchSize);

      if (side == 1) {
        branch.renderFlipX = true;
        branch.anchor = Anchor.bottomLeft;
        branch.position.x = this.width * 0.75;
        branch.overridePaint = new Paint()
          ..colorFilter = new ColorFilter.mode(
              Color.fromARGB(15, 255, 200, 200), BlendMode.srcATop);
      }

      this.addChild(branch, gameRef: this.game);
    }
  }
}
