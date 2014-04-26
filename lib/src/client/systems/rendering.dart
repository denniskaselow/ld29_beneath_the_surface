part of client;

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

class ControllerRenderingSystem extends SpatialRenderingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Controller> cm;
  ControllerRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [Controller]);

  @override
  void processEntity(Entity entity) {
    var x = tm.get(entity).pos.x;
    var state = cm.get(entity).active ? 'on' : 'off';
    var sprite = sheet.sprites['controller_$state'];
    var dst = sprite.dst;
    var src = sprite.src;
    ctx.drawImageScaledFromSource(sheet.image, src.left, src.top, src.width,
        src.height, dst.left + x, dst.top + 575, dst.width, dst.height);
  }
}

class PlayerRenderingSystem extends SpatialRenderingSystem {
  PlayerRenderingSystem(CanvasRenderingContext2D ctx, SpriteSheet sheet) : super(ctx, sheet, [PlayerInput]);
}