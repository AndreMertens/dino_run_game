enum ModusType { easy, middle, hard }

class ModusSettings {
  ModusType _modus = ModusType.middle;

  ModusType get modus => _modus;
  set modus(ModusType value) {
    _modus = value;
  }
}
