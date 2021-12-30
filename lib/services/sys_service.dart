import 'package:amberpencil/models/app_state_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state_model.dart';

class SysService {
  AppStateModel? _appStateModel;

  void _listen() {
    if (_appStateModel != null) {
      FirebaseFirestore.instance
          .collection('service')
          .doc('sys')
          .snapshots()
          .listen(
        (snap) {
          if (snap.exists) {
            _appStateModel!.version = snap.get('version');
            _appStateModel!.url = snap.get('url');
          }
        },
      );
    }
  }

  set appStateModel(AppStateModel appStateModel) {
    if (_appStateModel == null) {
      _appStateModel = appStateModel;
      _listen();
    }
  }
}
