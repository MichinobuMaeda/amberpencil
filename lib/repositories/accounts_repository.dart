import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import '../models/auth_user.dart';
import 'firestore_repository.dart';

class AccountsRepository extends FireStoreRepository {
  late void Function(List<Account>) _listener;
  late CollectionReference<Map<String, dynamic>> _ref;

  AccountsRepository({FirebaseFirestore? db})
      : super(db: db ?? FirebaseFirestore.instance);

  void start(void Function(List<Account>) listener) {
    _listener = listener;
    _ref = super.db.collection('accounts');
  }

  Future<Account?> restoreMe(AuthUser authUser) async {
    final snap = await _ref.doc(authUser.uid).get();
    return snap.exists ? Account(snap) : null;
  }

  @override
  void subscribe(Account me) {
    super.subscribe(me);
    listen(
      me.admin
          ? _ref.snapshots().listen(
                onQuerySnapshot,
                onError: onListenError,
              )
          : _ref.doc(me.id).snapshots().listen(
                onSnapshot,
                onError: onListenError,
              ),
    );
  }

  void onQuerySnapshot(QuerySnapshot<Map<String, dynamic>> querySnap) {
    _listener(querySnap.docs.map((snap) => Account(snap)).toList());
  }

  void onSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    _listener(snap.exists ? [Account(snap)] : []);
  }

  void onListenError(Object error, StackTrace stackTrace) {
    debugPrint('$error\n$stackTrace');
    _listener([]);
  }

  @override
  void unsubscribe() {
    cancel();
    super.unsubscribe();
  }

  Future<void> updateMe(
    Map<String, dynamic> data,
  ) =>
      update(uid ?? '', data); // assert later in updateDocument()

  Future<void> update(
    String id,
    Map<String, dynamic> data,
  ) =>
      updateDocument(_ref.doc(id), data);

  Future<void> delete(
    String id,
  ) =>
      deleteDocument(_ref.doc(id));
}
