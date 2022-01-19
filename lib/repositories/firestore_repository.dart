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

  void subscribe(Account me) {
    _uid = me.id;
  }

  void unsubscribe() {
    _uid = null;
  }

  void listen(StreamSubscription sub) {
    _sub?.cancel();
    _sub = sub;
  }

  void cancel() {
    _sub?.cancel();
    _sub = null;
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
