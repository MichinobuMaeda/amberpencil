import 'dart:convert';

class AppInfo {
  final String name;
  final String version;
  final String copyright;

  AppInfo({
    required this.name,
    required this.version,
    required this.copyright,
  });

  factory AppInfo.fromJson(String json) {
    final appInfo = const JsonDecoder().convert(json);
    return AppInfo(
      name: appInfo['name'],
      version: appInfo['version'],
      copyright: appInfo['copyright'],
    );
  }
}
