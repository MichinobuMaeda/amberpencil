import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conf.dart';
import 'service_provider.dart';

class ConfService extends ServiceProvider {
  final FirebaseFirestore _db;

  ConfService(FirebaseFirestore db)
      : _db = db,
        super('conf') {
    _db.collection('service').doc('conf').snapshots().listen(
      (snap) {
        final Conf conf = Conf.fromSnapshot(snap);
        if (data != conf) {
          update(Conf.fromSnapshot(snap));
        }
      },
      cancelOnError: true,
    );
  }

  Future<void> updateConfProperties(
    String updatedBy,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('service').doc('conf').update({
      ...data,
      'updatedBy': updatedBy,
      'updatedAt': DateTime.now(),
    });
  }
}
