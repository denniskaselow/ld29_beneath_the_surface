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
  int _bestKills = 0;
  bool running = false;

  bool get lost => chests == 0;
  bool get gameRunning => !lost && running;

  void set bestKills(int value) {
    _bestKills = value;
  }
  int get bestKills => kills > _bestKills ? kills : _bestKills;

  void reset() {
    chests = CHESTS;
    if (kills > _bestKills) {
      _bestKills = kills;
    }
    kills = 0;
  }
}