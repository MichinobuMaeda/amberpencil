import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_provider.dart';

class ConfData {
  final String? version;
  final String? url;
  final String? seed;
  final int? invitationExpirationTime;
  final String? policy;
  ConfData({
    this.version,
    this.url,
    this.seed,
    this.invitationExpirationTime,
    this.policy,
  });
}

class ConfService extends ServiceProvider<ConfData> {
  final FirebaseFirestore db;

  ConfService(this.db) : super(ConfData()) {
    db.collection('service').doc('conf').snapshots().listen((snap) {
      notify(
        ConfData(
          version: snap.exists ? snap.get('version') : null,
          url: snap.exists ? snap.get('url') : null,
          seed: snap.exists ? snap.get('seed') : null,
          invitationExpirationTime: snap.exists
              ? snap.get('invitationExpirationTime')
              : 24 * 3600 * 1000,
          policy: snap.exists ? snap.get('policy') : null,
        ),
      );
    });
  }
}
