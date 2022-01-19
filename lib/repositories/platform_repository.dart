import 'package:universal_html/html.dart' as html;

class PlatformRepository {
  final html.Window _window;
  final String _deepLink;

  static String getCurrentUrl() => html.window.location.href;

  PlatformRepository({
    required html.Window window,
    required String deepLink,
  })  : _window = window,
        _deepLink = deepLink;

  void reloadWebAapp() {
    _window.location.reload();
  }

  String get deepLink => _deepLink;

  void save(String key, String value) {
    _window.localStorage[key] = value;
  }

  String? load(String key, {bool reset = false}) {
    final String? value = _window.localStorage[key];
    if (reset) {
      _window.localStorage.remove(key);
    }
    return value;
  }
}
