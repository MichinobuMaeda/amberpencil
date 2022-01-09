import 'package:flutter/material.dart';
import '../config/app_info.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';

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

class AppInfoProvider extends ChangeNotifier with ServiceListener {
  AppInfo _data;
  final ConfService confService;

  AppInfoProvider(
    AppStaticInfo appStaticInfo,
    this.confService,
  ) : _data = AppInfo(appStaticInfo) {
    confService.registerListener(this);
  }

  @override
  void notify(dynamic data) {
    if (data is ConfData) {
      if (_data.policy != data.policy) {
        _data = AppInfo(_data, policy: data.policy);
        notifyListeners();
      }
    }
  }

  AppInfo get data => _data;
}
