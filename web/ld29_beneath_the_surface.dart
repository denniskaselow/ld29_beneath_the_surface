import 'package:ld29_beneath_the_surface/client.dart';

@MirrorsUsed(targets: const [WallRenderingSystem, ObstacleRenderingSystem,
                             ObstacleRenderingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super('ld29_beneath_the_surface', 'canvas', 1280, 720, bodyDefsName: null);

  void createEntities() {
    HttpRequest.getString('packages/ld29_beneath_the_surface/assets/levels/level0.txt').then((content) {
      var rows = content.split(new RegExp('\r\n'));
      for (int y = rows.length - 1; y >= 0; y--) {
        var tiles = rows[y].split('');
        for (int x = 0; x < tiles.length; x++) {
          switch (tiles[x]) {
            case 'B':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              break;
            case 'S':
              addEntity([new Transform(x * 50, y * 50), new Wall(), new Spatial('wall')]);
              addEntity([new Transform(x * 50, y * 50), new Obstacle(), new Spatial('spikes')]);
              break;

          }
        }
      }
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new WallRenderingSystem(canvas, spriteSheet),
            new ObstacleRenderingSystem(ctx, spriteSheet),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_beneath_the_surface')
    ];
  }

}
