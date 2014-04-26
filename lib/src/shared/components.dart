part of shared;

class Transform extends Component {
  Vector2 pos;
  Transform(num x, num y) : pos = new Vector2(x.toDouble(), y.toDouble());
}

class Wall extends Component {}

class Obstacle extends Component {}

class Spatial extends Component {
  String sprite;
  Spatial(this.sprite);
}