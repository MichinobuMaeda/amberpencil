import 'package:flutter/material.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';
import 'app_info.dart';

enum ClientState { loading, guest, pending, authenticated }

const ClientState initialClientState = ClientState.loading;

class AppInfoProvider extends ChangeNotifier with ServiceListener {
  AppInfo _appInfo;
  final ConfService confService;

  AppInfoProvider(
    AppStaticInfo appStaticInfo,
    this.confService,
  ) : _appInfo = AppInfo(appStaticInfo) {
    confService.registerListener(this);
  }

  @override
  void notify(dynamic data) {
    if (data is ConfData) {
      if (_appInfo.policy != data.policy) {
        _appInfo = AppInfo(_appInfo, policy: data.policy);
        notifyListeners();
      }
    }
  }

  AppInfo get appInfo => _appInfo;
}
