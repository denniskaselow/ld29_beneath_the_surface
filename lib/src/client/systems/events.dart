part of client;


class PlayerInputHandlingSystem extends EntityProcessingSystem {
  ComponentMapper<PlayerInput> pim;
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  PlayerInputHandlingSystem() : super(Aspect.getAspectForAllOf([PlayerInput]));

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

  void handleInput(KeyboardEvent event, bool pressed) {
    keyState[event.keyCode] = pressed;
    if (preventDefaultKeys.contains(event.keyCode)) {
      event.preventDefault();
    }
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

  @override
  bool checkProcessing() => gameState.gameRunning;
}

class EnemySpawningSystem extends VoidEntitySystem {
  SpriteSheet sheet;
  int spawnOnFrame = 1;
  int mod = 600;
  GroupManager gm;
  EnemySpawningSystem(this.sheet);

  void reset() {
    mod = 600;
    spawnOnFrame = (world.frame + 1) % mod;
  }

  @override
  void initialize() {
    eventBus.on(enemyDiedEvent).listen((_) {
      mod = max(120, (mod * 0.975).toInt());
      spawnOnFrame = (world.frame + 100) % mod;
    });
  }

  @override
  void processSystem() {
    var enemyType = random.nextInt(3);
    var enemy;
    switch(enemyType) {
      case 0:
        enemy = world.createAndAddEntity([new Enemy('stick', health: 1 + random.nextInt(2)),
                                  new Transform(0, 275),
                                  new Spatial('stickman'),
                                  new Acceleration(),
                                  new Velocity(),
                                  new Mass(),
                                  new BodyRect(sheet.sprites['stickman'].dst)]);
        break;
      case 1:
        enemy = world.createAndAddEntity([new Enemy('ring', health: 2 + random.nextInt(2)),
                                  new Transform(0, 275),
                                  new Spatial('green_hedgehog'),
                                  new Acceleration(),
                                  new Velocity(),
                                  new Mass(),
                                  new BodyRect(sheet.sprites['green_hedgehog'].dst)]);
        break;
      case 2:
        enemy = world.createAndAddEntity([new Enemy('blood', health: 2 + random.nextInt(2)),
                                  new Transform(0, 275),
                                  new Spatial('mexican_plumber'),
                                  new Acceleration(),
                                  new Velocity(),
                                  new Mass(),
                                  new BodyRect(sheet.sprites['mexican_plumber'].dst)]);
        break;
    }
    gm.add(enemy, GROUP_ENEMIES);
  }

  @override
  bool checkProcessing() => gameState.gameRunning && world.frame % mod == spawnOnFrame;
}


class HighScoreSavingSystem extends IntervalEntitySystem {
  static const KEY = 'highScore';
  Store store;
  HighScoreSavingSystem() : super(1000, Aspect.getEmpty());

  initialize() {
    store = new Store('ld29', 'kills');
    store.open().then((_) {
      store.getByKey(KEY).then((value) {
        if (null != value) {
          gameState.bestKills = value;
        }
      });
    });
  }

  @override
  processEntities(_) {
    store.getByKey(KEY).then((value) {
      if (null == value || value < gameState.kills) {
        store.save(gameState.kills, KEY);
      }
    });
  }
}