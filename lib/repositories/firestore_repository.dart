import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import '../models/firestore_model.dart';

abstract class FireStoreRepository {
  final FirebaseFirestore _db;
  String? _uid;
  StreamSubscription? _sub;

  FireStoreRepository({
    required FirebaseFirestore db,
  }) : _db = db;

  FirebaseFirestore get db => _db;

  String? get uid => _uid;

  Future<void> subscribe(Account me) async {
    _uid = me.id;
  }

  Future<void> unsubscribe() async {
    _uid = null;
  }

  Future<void> listen(StreamSubscription sub) async {
    await cancel();
    _sub = sub;
  }

  Future<void> cancel() async {
    if (_sub != null) {
      StreamSubscription sub = _sub!;
      _sub = null;
      await sub.cancel();
    }
  }

  Future<void> updateDocument(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    assert(_uid != null, 'Not authorized');
    await ref.update({
      ...data,
      FirestoreModel.fieldUpdatedAt: DateTime.now(),
      FirestoreModel.fieldUpdatedBy: _uid,
    });
  }

  Future<void> deleteDocument(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    assert(_uid != null, 'Not authorized');
    await ref.update({
      FirestoreModel.fieldDeletedAt: DateTime.now(),
      FirestoreModel.fieldDeletedBy: _uid,
    });
  }
}
