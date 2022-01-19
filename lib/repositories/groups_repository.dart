import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import '../models/group.dart';
import 'firestore_repository.dart';

class GroupsRepository extends FireStoreRepository {
  late void Function(List<Group>) _listener;
  late CollectionReference<Map<String, dynamic>> _ref;

  GroupsRepository({FirebaseFirestore? db})
      : super(db: db ?? FirebaseFirestore.instance);

  void start(void Function(List<Group>) listener) {
    _listener = listener;
    _ref = super.db.collection('accounts');
  }

  @override
  Future<void> subscribe(Account me) async {
    debugPrint('${(GroupsRepository).toString()}:subscribe');
    super.subscribe(me);
    listen((me.admin
            ? _ref
            : _ref.where(
                Group.fieldAccounts,
                arrayContains: me.id,
              ))
        .snapshots()
        .listen(
          onQuerySnapshot,
          onError: onListenError,
        ));
  }

  void onQuerySnapshot(QuerySnapshot<Map<String, dynamic>> querySnap) {
    _listener(querySnap.docs.map((snap) => Group(snap)).toList());
  }

  void onListenError(Object error, StackTrace stackTrace) {
    debugPrint(
      '${(GroupsRepository).toString()}:onListenError\n$error\n$stackTrace',
    );
    _listener([]);
  }

  @override
  Future<void> unsubscribe() async {
    debugPrint('${(GroupsRepository).toString()}:unsubscribe');
    super.unsubscribe();
    await cancel();
  }

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
