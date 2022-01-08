class AppStaticInfo {
  final String name;
  final String version;
  final String copyright;

  const AppStaticInfo({
    required this.name,
    required this.version,
    required this.copyright,
  });
}

const AppStaticInfo appStaticInfo = AppStaticInfo(
  name: 'Amber pencil',
  version: 'for test',
  copyright: 'Copyright 2021 Michinobu Maeda',
);
