import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_info.dart';
import '../models/auth_user.dart';
import '../models/conf.dart';

final testModeProvider = Provider<bool>(
  (_) => version.contains('test'),
);

final appTitileProvider = Provider<String>(
  (ref) => ref.watch(testModeProvider) ? 'Local test' : appName,
);

final authProvider = StateProvider<AuthUser>(
  (_) => const AuthUser(),
);

final confProvider = StateProvider<Conf?>(
  (_) => null,
);

final updateAvailableProvider = StateProvider<bool>(
  (ref) {
    String? avaliable = ref.watch(confProvider.select((conf) => conf?.version));
    return avaliable != null && avaliable != version;
  },
);
