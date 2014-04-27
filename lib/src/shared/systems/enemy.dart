part of shared;

class EnemyAiSystem extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  ComponentMapper<Velocity> vm;
  ComponentMapper<Transform> tm;
  ComponentMapper<BodyRect> brm;
  List<List<bool>> tileMap;
  EnemyAiSystem(this.tileMap) : super(Aspect.getAspectForAllOf([Enemy, Acceleration, Velocity, Transform, BodyRect]).exclude([InAir]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var v = vm.get(entity);
    var t = tm.get(entity);
    var rect = brm.get(entity).value;


    if (tileMap[2 + (t.pos.y - 25) ~/ 50][(t.pos.x + 25 + rect.width / 2) ~/ 50] == false &&
        tileMap[2 + (t.pos.y - 25) ~/ 50][3 + (t.pos.x + 25 + rect.width / 2) ~/ 50] == true) {
      // no tile below right, but something to jump onto
      a.value.y = world.delta * world.delta * -4.0;
      a.value.x = world.delta * world.delta * 0.5;
      entity.addComponent(new InAir());
      entity.changedInWorld();
    } else if (tileMap[2 + (t.pos.y - 25) ~/ 50][(t.pos.x + 50 + rect.width / 2) ~/ 50] == false &&
        tileMap[2 + (t.pos.y - 25) ~/ 50][3 + (t.pos.x + 50 + rect.width / 2) ~/ 50] == false &&
        v.value.x > 1.0) {
      // no tiles to the right, caution!
      a.value.x = world.delta * world.delta * -0.08;
    } else if (tileMap[(t.pos.y - 25) ~/ 50][(t.pos.x + 100 + rect.width / 2) ~/ 50] == true &&
        tileMap[-1 + (t.pos.y - 25) ~/ 50][(t.pos.x + 100 + rect.width / 2) ~/ 50] == false) {
      // a wall, jump onto it
      a.value.y = world.delta * world.delta * -5.0;
      a.value.x = world.delta * world.delta * 0.2;
      entity.addComponent(new InAir());
      entity.changedInWorld();
    } else if (tileMap[1 + (t.pos.y - 25) ~/ 50][(t.pos.x + 75 + rect.width / 2) ~/ 50] == true &&
        tileMap[(t.pos.y - 25) ~/ 50][(t.pos.x + 100 + rect.width / 2) ~/ 50] == false) {
      a.value.y = world.delta * world.delta * -4.0;
      a.value.x = world.delta * world.delta * 0.2;
      entity.addComponent(new InAir());
      entity.changedInWorld();
    } else {
      if (v.value.x < 20.0) {
        a.value.x = world.delta * world.delta * 0.5;
      } else {
        a.value.x = 0.0;
      }
    }
  }
}