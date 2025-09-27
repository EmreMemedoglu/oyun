import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';

void main() {
  runApp(GameWidget(game: FlappyClone()));
}

class FlappyClone extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  double gravity = 800;
  double gap = 180;
  double pipeSpeed = 150;
  late Sprite pipeSprite, bgSprite, groundSprite;
  int score = 0;
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    pipeSprite = await loadSprite('pipe.png');
    bgSprite = await loadSprite('bg.png');
    groundSprite = await loadSprite('ground.png');
    add(ParallaxComponent(parallax: Parallax(
      [ParallaxImage(bgSprite.image)],
      baseVelocity: Vector2(0,0),
      repeat: ImageRepeat.repeatX,
    )));

    bird = Bird()
      ..sprite = await loadSprite('bird.png')
      ..size = Vector2(48, 36)
      ..x = size.x * 0.2
      ..y = size.y / 2;
    add(bird);

    add(Ground()
      ..sprite = groundSprite
      ..size = Vector2(size.x, 48)
      ..y = size.y - 48);

    // spawn initial pipes
    for (int i = 0; i < 3; i++) {
      spawnPipe(size.x + i * 220);
    }
  }

  void spawnPipe(double x) {
    final rng = Random();
    final centerY = 100 + rng.nextDouble() * (size.y - 300);
    final topPipe = Pipe(pipeSprite, isTop: true)
      ..size = Vector2(64, size.y)
      ..x = x
      ..y = centerY - gap/2 - size.y; // place top above
    final bottomPipe = Pipe(pipeSprite, isTop: false)
      ..size = Vector2(64, size.y)
      ..x = x
      ..y = centerY + gap/2;
    add(topPipe);
    add(bottomPipe);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;
    // move pipes and recycle
    final pipes = children.whereType<Pipe>().toList();
    for (final p in pipes) {
      p.x -= pipeSpeed * dt;
      if (p.x + p.width < 0) {
        p.removeFromParent();
        if (!p.isTop) {
          // increment score only once per pair (bottom pipe crossing)
          score += 1;
        }
      }
    }
    // keep at least 3 pairs
    final pairs = children.whereType<Pipe>().length ~/2;
    if (pairs < 3) {
      spawnPipe(size.x + 220);
    }
  }

  void endGame() {
    gameOver = true;
    overlays.add('GameOver');
  }

  @override
  void onTap() {
    if (gameOver) {
      // restart
      children.where((c) => c is Pipe || c is Bird || c is Ground).forEach((c) => c.removeFromParent());
      score = 0;
      gameOver = false;
      onLoad();
    } else {
      bird.jump();
    }
  }
}

class Bird extends SpriteComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  double gravity = 800;
  Bird() {
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  void jump() {
    velocity.y = -250;
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity * dt;
    y += velocity.y * dt;
    if (y + height/2 > gameRef.size.y - 48) {
      // hit ground
      (gameRef as FlappyClone).endGame();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Pipe) {
      (gameRef as FlappyClone).endGame();
    }
  }
}

class Pipe extends SpriteComponent {
  final bool isTop;
  Pipe(Sprite sprite, {required this.isTop}) : super(sprite: sprite) {
    anchor = Anchor.topLeft;
    add(RectangleHitbox());
  }
}

class Ground extends SpriteComponent {
  Ground() {
    anchor = Anchor.topLeft;
  }
}