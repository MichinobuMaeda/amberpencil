import 'package:flutter/material.dart';
import '../models/conf.dart';
import '../services/service_listener.dart';
import '../services/conf_service.dart';

class ConfProvider extends ChangeNotifier with ServiceListener {
  final ConfService confService;
  Conf? _data;

  ConfProvider(
    this.confService,
  ) {
    confService.registerListener(this);
  }

  @override
  void notify(String key, dynamic data) {
    if (key == confService.key) {
      if (data is Conf && _data != data) {
        _data = data;
        notifyListeners();
      }
    }
  }

  Conf? get data => _data;
}
