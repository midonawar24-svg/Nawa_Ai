/// V13 - Boot State
enum BootState { initial, initializing, loadingUser, ready }

class BootStateManager {
  BootState _state = BootState.initial;
  BootState get state => _state;
  
  void setState(BootState newState) {
    _state = newState;
  }
}
