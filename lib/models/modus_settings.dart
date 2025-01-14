enum ModusType {
  easy,
  medium,
  hard,
}

class ModusSettings {
  ModusType _modus = ModusType.easy;

  ModusType get modus => _modus;
  set modus(ModusType value) {
    _modus = value;
  }
}
