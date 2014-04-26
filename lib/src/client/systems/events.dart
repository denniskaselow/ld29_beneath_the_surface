part of client;


class PlayerInputHandlingSystem extends EntityProcessingSystem {
  ComponentMapper<PlayerInput> pim;
  var keyState = <int, bool>{};
  PlayerInputHandlingSystem() : super(Aspect.getAspectForAllOf([PlayerInput]));

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

  void handleInput(KeyboardEvent event, bool pressed) {
    keyState[event.keyCode] = pressed;
  }

  @override
  void processEntity(Entity entity) {
    var pi = pim.get(entity);
    pi.left = false;
    pi.right = false;
    pi.action = false;
    if (keyState[KeyCode.A] == true || keyState[KeyCode.LEFT] == true) {
      pi.left = true;
    } else if (keyState[KeyCode.D] == true || keyState[KeyCode.RIGHT] == true) {
      pi.right = true;
    }
    if (keyState[KeyCode.W] == true || keyState[KeyCode.UP] == true) {
      pi.action = true;
    }
  }
}