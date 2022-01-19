import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conf.dart';
import 'firestore_repository.dart';

class ConfRepository extends FireStoreRepository {
  late void Function(Conf?) _listener;
  late DocumentReference<Map<String, dynamic>> _ref;

  ConfRepository({FirebaseFirestore? db})
      : super(db: db ?? FirebaseFirestore.instance);

  void start(void Function(Conf?) listener) {
    _listener = listener;
    _ref = super.db.collection('service').doc('conf');

    listen(_ref.snapshots().listen(onSnapshot, onError: onListenError));
  }

  void onSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    _listener(snap.exists ? Conf(snap) : null);
  }

  void onListenError(Object error, StackTrace stackTrace) {
    debugPrint('$error\n$stackTrace');
    _listener(null);
  }

  Future<void> updateField(
    Map<String, dynamic> data,
  ) =>
      updateDocument(_ref, data);

  @override
  Future<void> deleteDocument(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    assert(false, 'Not authorized');
  }
}
