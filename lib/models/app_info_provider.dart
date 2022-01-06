import 'package:flutter/material.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';
import 'app_info.dart';

enum ClientState { loading, guest, pending, authenticated }

const ClientState initialClientState = ClientState.loading;

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
