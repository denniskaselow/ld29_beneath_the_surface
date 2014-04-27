library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:tweenengine/tweenengine.dart';
export 'package:tweenengine/tweenengine.dart';

part 'src/shared/components.dart';

part 'src/shared/systems/enemy.dart';
part 'src/shared/systems/logic.dart';

const GROUP_TRAPS = 'traps';
const GROUP_ENEMIES = 'enemies';

final tweenManager = new TweenManager();
final enemyDiedEvent = new EventType<EnemyDiedEvent>();
final gameState = new GameState();

class EnemyDiedEvent {}

class GameState {
  static const CHESTS = 1;
  int chests = CHESTS;
  int kills = 0;

  bool get lost => chests == 0;
  bool get gameRunning => !lost;

  void reset() {
    chests = CHESTS;
    kills = 0;
  }
}