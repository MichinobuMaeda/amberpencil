import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Menu {
  none,
  back,
  add,
  edit,
  search,
  profile,
  preferences,
  about,
  development
}

final menuStateProvider = StateProvider<Menu>(
  (_) => Menu.none,
);
