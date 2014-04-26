import 'package:ld29_beneath_the_surface/client.dart';

@MirrorsUsed(targets: const [BlockRenderingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('ld29_beneath_the_surface', 'canvas', 1280, 720);

  void createEntities() {
    HttpRequest.getString('packages/ld29_beneath_the_surface/assets/levels/level0.txt').then((content) {
      var rows = content.split(new RegExp('\r\n'));
      print(rows.length);
      for (int y = rows.length - 1; y >= 0; y--) {
        var tiles = rows[y].split('');
        for (int x = 0; x < tiles.length; x++) {
          if (tiles[x] == 'B') {
            addEntity([new Block(x, y)]);
          }
        }
      }
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new BlockRenderingSystem(canvas),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_beneath_the_surface')
    ];
  }
}
