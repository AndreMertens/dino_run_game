import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/modus_settings.dart';
import 'modus.state.dart';

final modusNotifier =
    NotifierProvider<ModusState, ModusType>(() => ModusState());
