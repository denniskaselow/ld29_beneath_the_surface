import 'package:ld29_beneath_the_surface/client.dart';

@MirrorsUsed(targets: const [WallRenderingSystem, TrapRenderingSystem,
                             TrapRenderingSystem, ControllerRenderingSystem,
                             PlayerRenderingSystem, PlayerAccelerationSystem,
                             PlayerInputHandlingSystem, AccelerationSystem,
                             MovementSystem, ControllerActivatioSystem,
                             TrapMovementSystem, ControllerDelaySystm
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super('ld29_beneath_the_surface', 'canvas', 1280, 720, bodyDefsName: null);

  @override
  void createEntities() {
    var gm = world.getManager(GroupManager);
    HttpRequest.getString('packages/ld29_beneath_the_surface/assets/levels/level0.txt').then((content) {
      var rows = content.split(new RegExp('\r\n'));
      for (int y = rows.length - 1; y >= 0; y--) {
        var tiles = rows[y].split('');
        for (int x = 0; x < tiles.length; x++) {
          switch (tiles[x]) {
            case 'B':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              break;
            case 'v':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              var e = addEntity([new Transform(x * 50, y * 50), new Trap(), new Spatial('spikes'), new Controller(), new TrapMover(0.0, 25.0)]);
              gm.add(e, GROUP_CONTROLLER);
              break;
            case '^':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              var e = addEntity([new Transform(x * 50, y * 50), new Trap(), new Spatial('spikes'), new Controller(), new TrapMover(0.0, -25.0)]);
              gm.add(e, GROUP_CONTROLLER);
              break;

          }
        }
      }
    });
    addEntity([new PlayerInput(), new Transform(1200, 575), new Spatial('player'), new Acceleration(), new Velocity()]);
  }

  @override
  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new PlayerInputHandlingSystem(),
            new PlayerAccelerationSystem(),
            new AccelerationSystem(),
            new MovementSystem(),
            new ControllerDelaySystm(),
            new ControllerActivatioSystem(),
            new TrapMovementSystem(),
            new CanvasCleaningSystem(canvas),
            new TrapRenderingSystem(ctx, spriteSheet),
            new WallRenderingSystem(canvas, spriteSheet),
            new ControllerRenderingSystem(ctx, spriteSheet),
            new PlayerRenderingSystem(ctx, spriteSheet),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_beneath_the_surface')
    ];
  }

  @override
  onInit() {
    world.addManager(new GroupManager());
  }

}
