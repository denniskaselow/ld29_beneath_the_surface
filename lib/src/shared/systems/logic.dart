part of shared;

class PlayerAccelerationSystem extends EntityProcessingSystem {
  ComponentMapper<PlayerInput> pim;
  ComponentMapper<Acceleration> am;
  PlayerAccelerationSystem() : super(Aspect.getAspectForAllOf([PlayerInput, Acceleration]));

  @override
  void processEntity(Entity entity) {
    var pi = pim.get(entity);
    var a = am.get(entity);

    if (pi.left) {
      a.value = new Vector2(-40.0, 0.0);
    } else if (pi.right) {
      a.value = new Vector2(40.0, 0.0);
    } else {
      a.value.setZero();
    }
  }
}

class AccelerationSystem extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  ComponentMapper<Velocity> vm;
  AccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var v = vm.get(entity);

    if (a.value.x == 0.0 && a.value.y == 0.0) {
      Vector2 drag = new Vector2(100 / world.delta, 100 / world.delta);
      Vector2.min(new Vector2.copy(v.value).absolute(), drag, drag);
      drag.x = drag.x * v.value.x.sign;
      drag.y = drag.y * v.value.y.sign;
      v.value -= drag;
    } else {
      v.value = v.value + a.value / world.delta;
      v.value.x = v.value.x.sign * min(v.value.x.abs(), 100.0);
    }
  }
}

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Velocity> vm;
  ComponentMapper<BodyRect> brm;
  List<List<bool>> tileMap;
  MovementSystem(this.tileMap) : super(Aspect.getAspectForAllOf([Transform, Velocity, BodyRect]));

  @override
  void processEntity(Entity entity) {
    var v = vm.get(entity);
    var t = tm.get(entity);
    var rect = brm.get(entity).value;

    t.pos = t.pos + v.value / world.delta;
    // tile below
    if (tileMap[2 + (t.pos.y - 24) ~/ 50][(t.pos.x + 25) ~/ 50] == true) {
      t.pos.y = (t.pos.y ~/ 50) * 50.0 + 25.0;
      v.value.y = 0.0;
      entity.removeComponent(InAir);
    } else {
      entity.addComponent(new InAir());
    }
    // tile to the right
    if (tileMap[(t.pos.y) ~/ 50][(t.pos.x + 25.0 + rect.width / 2) ~/ 50] == true) {
      t.pos.x = ((t.pos.x + 25 + rect.width / 2) ~/ 50) * 50.0 - (50 + rect.width) / 2;
      v.value.x = 0.0;
    }
    entity.changedInWorld();
  }
}

class ControllerActivatioSystem extends EntityProcessingSystem {
  ComponentMapper<PlayerInput> pim;
  ComponentMapper<Transform> tm;
  ComponentMapper<Controller> cm;
  ComponentMapper<Spatial> sm;
  GroupManager gm;
  ControllerActivatioSystem() : super(Aspect.getAspectForAllOf([PlayerInput, Transform]));

  @override
  void processEntity(Entity entity) {
    if (pim.get(entity).action) {
      var playerX = tm.get(entity).pos.x;
      gm.getEntities(GROUP_TRAPS).forEach((controllerEntity) {
        var controller = cm.get(controllerEntity);
        var controllerX = tm.get(controllerEntity).pos.x;
        if (controllerX > playerX - 25.0 && controllerX < playerX + 25.0 && !controller.active) {
          controller.active = !controller.active;
          controllerEntity.addComponent(new TrapTimer(timeLeft: controller.timer));
          controllerEntity.changedInWorld();
          controller.timeLeft = controller.timer + 1200.0;
          var label = sm.get(controllerEntity).sprite;
          eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Activate Trap', label));
        }
      });
    }
  }
}

class ControllerDelaySystm extends EntityProcessingSystem {
  ComponentMapper<Controller> cm;
  ControllerDelaySystm() : super(Aspect.getAspectForAllOf([Controller]));

  @override
  void processEntity(Entity entity) {
    var c = cm.get(entity);
    if (c.active) {
      c.timeLeft -= world.delta;
      if (c.timeLeft < 0.0) {
        c.active = false;
      }
    }
  }
}

class TrapMovementSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<TrapMover> omm;
  ComponentMapper<TrapTimer> otm;
  TrapMovementSystem() : super(Aspect.getAspectForAllOf([Transform, TrapMover, TrapTimer]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var om = omm.get(entity);
    var ot = otm.get(entity);

    Timeline.createSequence()
        ..push(Tween.to(t, Transform.TWEEN_POS, ot.timeLeft * 0.1)
            ..targetRelative = [om.maxMovement.x, om.maxMovement.y]
            ..easing = Quint.OUT)
        ..pushPause(1000.0)
        ..push(Tween.to(t, Transform.TWEEN_POS, ot.timeLeft * 0.9)
            ..targetRelative = [-om.maxMovement.x, -om.maxMovement.y]
            ..easing = Quint.IN)
        ..start(tweenManager);

    entity.removeComponent(TrapTimer);
    entity.changedInWorld();
  }
}

class TweeningSystem extends VoidEntitySystem {

  @override
  void processSystem() {
    tweenManager.update(world.delta);
  }
}

class GravitySysteme extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  GravitySysteme() : super(Aspect.getAspectForAllOf([Mass, Acceleration]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);

    // 50px == 1m
    a.value.y = 500.0 / world.delta;
  }
}

class AccelerationResettingSystem extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  AccelerationResettingSystem() : super(Aspect.getAspectForAllOf([Acceleration]));

  @override
  void processEntity(Entity entity) {
    am.get(entity).value.setZero();
  }
}

class EnemyWithTrapCollisionSystem extends EntityProcessingSystem {
  ComponentMapper<Enemy> em;
  ComponentMapper<BodyRect> brm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Controller> cm;
  GroupManager gm;
  EnemyWithTrapCollisionSystem() : super(Aspect.getAspectForAllOf([Enemy, BodyRect, Transform]).exclude([Invulnerability]));


  @override
  void processEntity(Entity entity) {
    var pos = tm.get(entity).pos;
    var enemyRect = brm.get(entity).value;
    var enemyRectAtPos = getRectAtPos(enemyRect, pos);
    gm.getEntities(GROUP_TRAPS).where((trap) => cm.get(trap).active).forEach((trap) {
      var trapPos = tm.get(trap).pos;
      var trapRect = brm.get(trap).value;
      Rectangle trapRectAtPos = getRectAtPos(trapRect, trapPos);
      if (trapRectAtPos.intersects(enemyRectAtPos)) {
        print(trapRectAtPos);
        print(enemyRectAtPos);
        var e = em.get(entity);
        e.health -= 1;
        if (e.health == 0) {
          entity.deleteFromWorld();
        } else {
          entity.addComponent(new Invulnerability());
          entity.changedInWorld();
        }
        return;
      }
    });
  }

  Rectangle getRectAtPos(Rectangle rect, Vector2 pos) {
    return new Rectangle(rect.left + pos.x, rect.top + pos.y, rect.width, rect.height);
  }
}

class InvulnerabilityDecayingSystem extends EntityProcessingSystem {
  ComponentMapper<Invulnerability> im;
  InvulnerabilityDecayingSystem() : super(Aspect.getAspectForAllOf([Invulnerability]));

  @override
  void processEntity(Entity entity) {
    var i = im.get(entity);
    i.delay -= world.delta;
    if (i.delay < 0.0) {
      entity.removeComponent(Invulnerability);
      entity.changedInWorld();
    }
  }
}