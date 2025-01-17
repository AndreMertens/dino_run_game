import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/modus_settings.dart';

class ModusState extends Notifier<ModusType> {
  @override
  ModusType build() {
    return ModusType.easy;
  }

  void updateState(ModusType newState) {
    state = newState;
  }
}
