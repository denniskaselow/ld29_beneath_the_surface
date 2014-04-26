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
        tileMap[2 + (t.pos.y - 25) ~/ 50][2 + (t.pos.x + 25 + rect.width / 2) ~/ 50] == true) {
      // no tile below right
      a.value.y = -500.0;
      a.value.x = 1.0;
      entity.addComponent(new InAir());
      entity.changedInWorld();
    } else if (tileMap[1 + (t.pos.y - 25) ~/ 50][(t.pos.x + 100 + rect.width / 2) ~/ 50] == true) {
      a.value.y = -800.0;
      a.value.x = -5.0;
      entity.addComponent(new InAir());
      entity.changedInWorld();
    } else {
      if (v.value.x < 20.0) {
        a.value.x = 4.0;
      } else {
        a.value.x = 0.0;
      }
    }
  }
}