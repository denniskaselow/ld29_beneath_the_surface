part of client;

class BackgroundRenderingSystem extends EntitySystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spatial> sm;
  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  bool buffered = false;
  SpriteSheet sheet;
  BackgroundRenderingSystem(CanvasElement canvas, this.sheet)
      : ctx = canvas.context2D,
        buffer = new CanvasElement(width: canvas.width, height: canvas.height),
        super(Aspect.getAspectForAllOf([Transform, Background, Spatial]));

  @override
  void processEntities(Iterable<Entity> entities) {
    if (!buffered) {
      entities.forEach((entity) {
        var sprite = sheet.sprites[sm.get(entity).sprite];
        var dst = sprite.dst;
        var src = sprite.src;
        var pos = tm.get(entity).pos;
        buffer.context2D.drawImageScaledFromSource(sheet.image, src.left,
            src.top, src.width, src.height, dst.left + pos.x, dst.top + pos.y, dst.width, dst.height);
      });
      buffered = true;
    }
    ctx.drawImage(buffer, 0, 0);
  }

  @override
  bool checkProcessing() => true;
}

class WallRenderingSystem extends EntitySystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spatial> sm;
  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  bool buffered = false;
  SpriteSheet sheet;
  WallRenderingSystem(CanvasElement canvas, this.sheet)
      : ctx = canvas.context2D,
        buffer = new CanvasElement(width: canvas.width, height: canvas.height),
        super(Aspect.getAspectForAllOf([Transform, Wall, Spatial]));

  @override
  void processEntities(Iterable<Entity> entities) {
    if (!buffered) {
      entities.forEach((entity) {
        var sprite = sheet.sprites[sm.get(entity).sprite];
        var dst = sprite.dst;
        var src = sprite.src;
        var pos = tm.get(entity).pos;
        buffer.context2D.drawImageScaledFromSource(sheet.image, src.left,
            src.top, src.width, src.height, dst.left + pos.x, dst.top + pos.y, dst.width, dst.height);
      });
      buffered = true;
    }
    ctx.drawImage(buffer, 0, 0);
  }

  @override
  bool checkProcessing() => true;
}

abstract class SpatialRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spatial> sm;
  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  SpatialRenderingSystem(this.ctx, this.sheet, List<Type> types) : super(Aspect.getAspectForAllOf([Spatial, Transform]).allOf(types));

  @override
  void processEntity(Entity entity) {
    var sprite = sheet.sprites[sm.get(entity).sprite];
    var dst = sprite.dst;
    var src = sprite.src;
    var pos = tm.get(entity).pos;
    ctx.drawImageScaledFromSource(sheet.image, src.left, src.top, src.width,
        src.height, dst.left + pos.x, dst.top + pos.y, dst.width, dst.height);
  }
}

class TrapRenderingSystem extends SpatialRenderingSystem {
  TrapRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [Trap]);
}

class EnemyRenderingSystem extends SpatialRenderingSystem {
  EnemyRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [Enemy]);
}

class EffectRenderingSystem extends SpatialRenderingSystem {
  ComponentMapper<Effect> em;
  EffectRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [Effect]);

  @override
  void begin() {
    ctx.save();
  }

  @override
  void processEntity(Entity entity) {
    ctx.globalAlpha = em.get(entity).alpha;
    super.processEntity(entity);
  }

  @override
  void end() {
    ctx.restore();
  }
}

class ControllerRenderingSystem extends SpatialRenderingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Controller> cm;
  ControllerRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [Controller]);

  @override
  void processEntity(Entity entity) {
    var controller = cm.get(entity);
    var state = controller.active ? 'on' : 'off';
    var sprite = sheet.sprites['controller_$state'];
    var dst = sprite.dst;
    var src = sprite.src;
    ctx.drawImageScaledFromSource(sheet.image, src.left, src.top, src.width,
        src.height, dst.left + controller.x, dst.top + 550, dst.width, dst.height);
  }
}

class PlayerRenderingSystem extends SpatialRenderingSystem {
  PlayerRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [PlayerInput]);
}

class DebugRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<BodyRect> brm;
  CanvasRenderingContext2D ctx;
  DebugRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform, BodyRect]));

  @override
  void processEntity(Entity entity) {
    var pos = tm.get(entity).pos;
    var rect = brm.get(entity).value;
    var dst = getRectAtPos(rect, pos);
    ctx..save()
       ..strokeStyle = 'white'
       ..strokeRect(dst.left, dst.top, dst.width, dst.height)
       ..restore();
  }

  Rectangle getRectAtPos(Rectangle rect, Vector2 pos) {
    return new Rectangle(rect.left + pos.x, rect.top + pos.y, rect.width, rect.height);
  }
}

class LosingScreenRenderSystem extends VoidEntitySystem {
  static const headline = 'You have failed!';
  static const tryAgain = 'Try again!';
  CanvasElement canvas;
  CanvasQuery buffer;
  Point<num> mousePos = new Point<num>(0, 0);
  Rectangle headlineBounds;
  Rectangle tryAgainBounds;
  Rectangle tryAgainRect;
  bool clicked = false;
  EnemySpawningSystem ess;
  GroupManager gm;
  LosingScreenRenderSystem(this.canvas);

  @override
  void initialize() {
    buffer = cq(canvas.width, canvas.height);
    buffer..textBaseline = 'top'
          ..font = '30px Verdana';
    headlineBounds = buffer.textBoundaries(headline);
    tryAgainBounds = buffer.textBoundaries(tryAgain);
    tryAgainRect = new Rectangle(canvas.width ~/ 2 - tryAgainBounds.width ~/ 2 - 10, canvas.height ~/ 2 + 100 - tryAgainBounds.height - 30, tryAgainBounds.width + 20, tryAgainBounds.height + 20);

    canvas.onMouseMove.listen((event) {
      if (gameState.lost) {
        mousePos = event.offset;
      }
    });
    canvas.onMouseDown.listen((event) {
      if (gameState.lost) {
        clicked = true;
      }
    });
    canvas.onMouseUp.listen((event) => clicked = false);
  }

  @override
  void processSystem() {
    var mouseInTryAgain = tryAgainRect.containsPoint(mousePos);
    buffer
      ..clear()
      ..font = '30px Verdana'
      ..roundRect(canvas.width ~/ 2 - 200, canvas.height ~/ 2 - 100, 400, 200, 20, strokeStyle: 'black', fillStyle: '#3f3f74')
      ..wrappedText(headline, canvas.width ~/ 2 - headlineBounds.width ~/ 2, canvas.height ~/ 2 - 100, 360)
      ..roundRect(tryAgainRect.left, tryAgainRect.top, tryAgainRect.width, tryAgainRect.height, 20, strokeStyle: 'black', fillStyle: mouseInTryAgain ? '#639bff' : '#306082')
      ..wrappedText(tryAgain, canvas.width ~/ 2 - tryAgainBounds.width ~/ 2, canvas.height ~/ 2 + 100 - tryAgainBounds.height - 20, 360)
      ..font = '18px Verdana'
      ..wrappedText('''
The heroes have looted all the treasure chests!
The lord of the castle isn't satisified with your performance.
You only killed ${gameState.kills} heroes.
    ''', canvas.width ~/ 2 - 180, canvas.height ~/ 2 - 60, 360);
    canvas.context2D.drawImage(buffer.canvas, 0, 0);

    if (clicked && mouseInTryAgain) {
      gameState.reset();
      ess.reset();
      gm.getEntities(GROUP_ENEMIES).forEach((enemy) => enemy.deleteFromWorld());
      eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Try again', 'Game'));
    }
  }

  bool checkProcessing() => gameState.lost;
}

class StartMenuRenderingSystem extends VoidEntitySystem {
  static const headline = 'Welcome castle engineer!';
  static const startGame = 'Start game';
  CanvasElement canvas;
  CanvasQuery buffer;
  Point<num> mousePos = new Point<num>(0, 0);
  Rectangle headlineBounds;
  Rectangle startGameBounds;
  Rectangle startGameRect;
  bool clicked = false;
  EnemySpawningSystem ess;
  GroupManager gm;
  StartMenuRenderingSystem(this.canvas);

  @override
  void initialize() {
    buffer = cq(canvas.width, canvas.height);
    buffer..textBaseline = 'top'
          ..font = '30px Verdana';
    headlineBounds = buffer.textBoundaries(headline);
    startGameBounds = buffer.textBoundaries(startGame);
    startGameRect = new Rectangle(canvas.width ~/ 2 - startGameBounds.width ~/ 2 - 10, canvas.height ~/ 2 + 100 - startGameBounds.height - 30, startGameBounds.width + 20, startGameBounds.height + 20);

    canvas.onMouseMove.listen((event) {
      if (!gameState.running) {
        mousePos = event.offset;
      }
    });
    canvas.onMouseDown.listen((event) {
      if (!gameState.running) {
        clicked = true;
      }
    });
    canvas.onMouseUp.listen((event) => clicked = false);
  }

  @override
  void processSystem() {
    var mouseInStartGame = startGameRect.containsPoint(mousePos);
    buffer
      ..clear()
      ..font = '30px Verdana'
      ..roundRect(canvas.width ~/ 2 - 300, canvas.height ~/ 2 - 100, 600, 200, 20, strokeStyle: 'black', fillStyle: '#3f3f74')
      ..wrappedText(headline, canvas.width ~/ 2 - headlineBounds.width ~/ 2, canvas.height ~/ 2 - 100, 560)
      ..roundRect(startGameRect.left, startGameRect.top, startGameRect.width, startGameRect.height, 20, strokeStyle: 'black', fillStyle: mouseInStartGame ? '#639bff' : '#306082')
      ..wrappedText(startGame, canvas.width ~/ 2 - startGameBounds.width ~/ 2, canvas.height ~/ 2 + 100 - startGameBounds.height - 20, 560)
      ..font = '18px Verdana'
      ..wrappedText('''
Usually, one engineer is responsible for one trap. but today, everyone has gone to the beach, except for you.
Now it's your duty to keep all the traps running to protect the treasure chest of your Demon Lord.
    ''', canvas.width ~/ 2 - 280, canvas.height ~/ 2 - 60, 560);
    canvas.context2D.drawImage(buffer.canvas, 0, 0);

    if (clicked && mouseInStartGame) {
      gameState.running = true;
      ess.reset();
    }
  }

  bool checkProcessing() => !gameState.running;
}

class GameStateRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  GameStateRenderingSystem(this.ctx, this.sheet);

  @override
  void processSystem() {
    var chest = sheet.sprites['chest'];
    for (int i = 0; i < gameState.chests; i++) {
      ctx.drawImageScaledFromSource(sheet.image, chest.src.left, chest.src.top, chest.src.width, chest.src.height, 50 + i * 50, 650, chest.dst.width, chest.dst.height);
    }
    var killWidth = ctx.measureText('${gameState.kills}').width;
    var bestKillWidth = ctx.measureText('${gameState.bestKills}').width;
    ctx..fillText('Defeated Hearoes (current):', 1000, 650)
       ..fillText('${gameState.kills}', 1250 - killWidth, 650)
       ..fillText('Defeated Hearoes (best):', 1000, 675)
       ..fillText('${gameState.bestKills}', 1250 - bestKillWidth, 675);
  }
}

