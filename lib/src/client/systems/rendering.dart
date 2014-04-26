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

class ObstacleRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spatial> sm;
  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  ObstacleRenderingSystem(this.ctx, this.sheet) : super(
      Aspect.getAspectForAllOf([Transform, Spatial, Obstacle]));


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
