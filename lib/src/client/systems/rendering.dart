part of client;

class BlockRenderingSystem extends EntitySystem {
  CanvasRenderingContext2D ctx;
  ComponentMapper<Block> bm;
  CanvasElement buffer;
  bool buffered = false;
  BlockRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        buffer = new CanvasElement(width: canvas.width, height: canvas.height),
        super(Aspect.getAspectForAllOf([Block]));

  @override
  void processEntities(Iterable<Entity> entities) {
    if (!buffered) {
      entities.forEach((entity) {
      var b = bm.get(entity);
      buffer.context2D
          ..fillStyle = 'black'
          ..fillRect(b.x * 50, b.y * 50, 50, 50);
      });
      buffered = true;
    }
    ctx.drawImage(buffer, 0, 0);
  }

  @override
  bool checkProcessing() => true;
}
