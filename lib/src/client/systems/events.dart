part of client;


class PlayerInputHandlingSystem extends EntityProcessingSystem {
  ComponentMapper<PlayerInput> pim;
  var keyState = <int, bool>{};
  PlayerInputHandlingSystem() : super(Aspect.getAspectForAllOf([PlayerInput]));

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

  void handleInput(KeyboardEvent event, bool pressed) {
    keyState[event.keyCode] = pressed;
  }

  @override
  void processEntity(Entity entity) {
    var pi = pim.get(entity);
    pi.left = false;
    pi.right = false;
    pi.action = false;
    if (keyState[KeyCode.A] == true || keyState[KeyCode.LEFT] == true) {
      pi.left = true;
    } else if (keyState[KeyCode.D] == true || keyState[KeyCode.RIGHT] == true) {
      pi.right = true;
    }
    if (keyState[KeyCode.W] == true || keyState[KeyCode.UP] == true) {
      pi.action = true;
    }
  }
}

class EnemySpawningSystem extends VoidEntitySystem {
  SpriteSheet sheet;
  int spawnOnFrame = 1;
  int mod = 1000;
  EnemySpawningSystem(this.sheet);

  @override
  void initialize() {
    eventBus.on(enemyDiedEvent).listen((_) {
      mod = max(120, (mod * 0.95).toInt());
      spawnOnFrame = (world.frame + 100) % mod;
    });
  }

  @override
  void processSystem() {
    world.createAndAddEntity([new Enemy(health: 2),
                              new Transform(0, 275),
                              new Spatial('stickman'),
                              new Acceleration(),
                              new Velocity(),
                              new Mass(),
                              new BodyRect(sheet.sprites['stickman'].dst)]);
  }

  @override
  bool checkProcessing() => world.frame % mod == spawnOnFrame;
}