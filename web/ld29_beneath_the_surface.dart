import 'package:ld29_beneath_the_surface/client.dart';

@MirrorsUsed(targets: const [
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('ld29_beneath_the_surface', 'canvas', 800, 600);

  void createEntities() {
    // addEntity([Component1, Component2]);
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld29_beneath_the_surface')
    ];
  }
}
