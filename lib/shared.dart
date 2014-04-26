library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:tweenengine/tweenengine.dart';

part 'src/shared/components.dart';

part 'src/shared/systems/enemy.dart';
part 'src/shared/systems/logic.dart';

const GROUP_CONTROLLER = 'controller';

final tweenManager = new TweenManager();