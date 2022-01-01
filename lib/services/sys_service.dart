import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_provider.dart';

class SysData {
  final String? version;
  final String? url;
  SysData({this.version, this.url});
}

class SysService extends ServiceProvider<SysData> {
  final FirebaseFirestore db;

  SysService(this.db) : super(SysData()) {
    db.collection('service').doc('sys').snapshots().listen((snap) {
      notify(
        SysData(
          version: snap.exists ? snap.get('version') : null,
          url: snap.exists ? snap.get('url') : null,
        ),
      );
    });
  }
}
