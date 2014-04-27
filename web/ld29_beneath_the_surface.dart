import 'package:ld29_beneath_the_surface/client.dart';

@MirrorsUsed(targets: const [WallRenderingSystem, TrapRenderingSystem,
                             TrapRenderingSystem, ControllerRenderingSystem,
                             PlayerRenderingSystem, PlayerAccelerationSystem,
                             PlayerInputHandlingSystem, AccelerationSystem,
                             MovementSystem, ControllerActivatioSystem,
                             TrapMovementSystem, ControllerDelaySystm,
                             EnemyRenderingSystem, EnemyAiSystem,
                             GravitySysteme, AccelerationResettingSystem,
                             BackgroundRenderingSystem, EnemyWithTrapCollisionSystem,
                             DebugRenderingSystem, InvulnerabilityDecayingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  List<List<bool>> tileMap;

  Game() : super('ld29_beneath_the_surface', 'canvas', 1280, 720, bodyDefsName: null);

  @override
  void createEntities() {
    addEntity([new PlayerInput(), new Transform(100, 575), new Spatial('player'), new Acceleration(), new Velocity(), new BodyRect(spriteSheet.sprites['player'].dst)]);
    addEntity([new Enemy(health: 2), new Transform(0, 275), new Spatial('stickman'), new Acceleration(), new Velocity(), new Mass(), new BodyRect(spriteSheet.sprites['stickman'].dst)]);
  }

  @override
  List<EntitySystem> getSystems() {
    return [
            new AccelerationResettingSystem(),
            new TweeningSystem(),
            new GravitySysteme(),
            new EnemyAiSystem(tileMap),
            new PlayerInputHandlingSystem(),
            new PlayerAccelerationSystem(),
            new AccelerationSystem(),
            new MovementSystem(tileMap),
            new ControllerDelaySystm(),
            new ControllerActivatioSystem(),
            new TrapMovementSystem(),
            new EnemyWithTrapCollisionSystem(),
            new CanvasCleaningSystem(canvas),
            new BackgroundRenderingSystem(canvas, spriteSheet),
            new TrapRenderingSystem(ctx, spriteSheet),
            new WallRenderingSystem(canvas, spriteSheet),
            new ControllerRenderingSystem(ctx, spriteSheet),
            new EnemyRenderingSystem(ctx, spriteSheet),
            new PlayerRenderingSystem(ctx, spriteSheet),
//            new DebugRenderingSystem(ctx),
            new FpsRenderingSystem(ctx),
            new InvulnerabilityDecayingSystem(),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_beneath_the_surface')
    ];
  }

  @override
  Future onInit() {
    world.addManager(new GroupManager());

    var gm = world.getManager(GroupManager);
    return HttpRequest.getString('packages/ld29_beneath_the_surface/assets/levels/level0.txt').then((content) {
      var rows = content.split(new RegExp('\r\n'));
      tileMap = new List(rows.length);
      for (int y = rows.length - 1; y >= 0; y--) {
        var tiles = rows[y].split('');
        tileMap[y] = new List<bool>.filled(tiles.length, true);
        for (int x = 0; x < tiles.length; x++) {
          switch (tiles[x]) {
            case 'B':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              break;
            case 'v':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              var e = addEntity([new Transform(x * 50, y * 50),
                                 new Trap(),
                                 new Spatial('spikes'),
                                 new BodyRect(spriteSheet.sprites['spikes'].dst),
                                 new Controller(),
                                 new TrapMover(0.0, 25.0)]);
              gm.add(e, GROUP_TRAPS);
              break;
            case '^':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              var e = addEntity([new Transform(x * 50, y * 50),
                                 new Trap(),
                                 new Spatial('spikes'),
                                 new BodyRect(spriteSheet.sprites['spikes'].dst),
                                 new Controller(),
                                 new TrapMover(0.0, -25.0)]);
              gm.add(e, GROUP_TRAPS);
              break;
            default:
              addEntity([new Transform(x * 50, y * 50), new Background(), new Spatial('background')]);
              tileMap[y][x] = false;
              break;
          }
        }
      }
    });
  }

}
