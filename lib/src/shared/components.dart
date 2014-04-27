part of shared;

class Transform extends Component implements Tweenable {
  static const TWEEN_POS = 0;
  Vector2 pos;
  Transform(num x, num y) : pos = new Vector2(x.toDouble(), y.toDouble());

  @override
  int getTweenableValues(int tweenType, List<num> returnValues) {
    switch (tweenType) {
      case TWEEN_POS:
        returnValues[0] = pos.x;
        returnValues[1] = pos.y;
        return 2;
      default:
        return 0;
    }
  }

  @override
  void setTweenableValues(int tweenType, List<num> newValues) {
    switch (tweenType) {
      case TWEEN_POS:
        pos.x = newValues[0];
        pos.y = newValues[1];
        break;
      default:
        break;
    }
  }
}

class Background extends Component {}
class Wall extends Component {}
class Enemy extends Component {}
class Trap extends Component {}
class TrapTimer extends Component {
  double timeLeft = 0.0;
  TrapTimer({this.timeLeft: 1000.0});
}
class Mass extends Component {}

class Spatial extends Component {
  String sprite;
  Spatial(this.sprite);
}

class Controller extends Component {
  bool active = false;
  final double timer;
  double timeLeft;
  Controller({this.timer: 1000.0});
}

class PlayerInput extends Component {
  bool right = false;
  bool left = false;
  bool action = false;
}

class Acceleration extends Component {
  Vector2 value = new Vector2.zero();
}

class Velocity extends Component {
  Vector2 value = new Vector2.zero();
}

class TrapMover extends Component {
  Vector2 maxMovement;
  Vector2 currentMovement = new Vector2.zero();
  TrapMover(num x, num y) : maxMovement = new Vector2(x.toDouble(), y.toDouble());
}

class BodyRect extends Component {
  Rectangle value;
  BodyRect(this.value);
}

class InAir extends Component {}