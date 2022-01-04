import 'dart:convert';

class AppStaticInfo {
  final String name;
  final String version;
  final String copyright;

  AppStaticInfo({
    required this.name,
    required this.version,
    required this.copyright,
  });

  factory AppStaticInfo.fromJson(String json) {
    final appInfo = const JsonDecoder().convert(json);
    return AppStaticInfo(
      name: appInfo['name'],
      version: appInfo['version'],
      copyright: appInfo['copyright'],
    );
  }
}

class AppInfo extends AppStaticInfo {
  final String? policy;

  AppInfo(
    AppStaticInfo appStaticInfo, {
    this.policy,
  }) : super(
          name: appStaticInfo.name,
          version: appStaticInfo.version,
          copyright: appStaticInfo.copyright,
        );
}
