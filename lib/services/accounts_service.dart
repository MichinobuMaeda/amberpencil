// import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'service_provider.dart';

class AccountData {
  final String? id;
  final String? name;
  final String? email;
  final String? group;
  final bool admin;
  final bool tester;
  final int themeMode;

  AccountData()
      : id = null,
        name = null,
        email = null,
        group = null,
        admin = false,
        tester = false,
        themeMode = 0;

  AccountData.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap)
      : id = snap.id,
        name = snap.get('name'),
        email = snap.get('email'),
        group = snap.get('group'),
        admin = snap.get('admin') ?? false,
        tester = snap.get('tester') ?? false,
        themeMode = snap.get('themeMode') ?? 0;

  AccountData.from(AccountData data)
      : id = data.id,
        name = data.name,
        email = data.email,
        group = data.group,
        admin = data.admin,
        tester = data.tester,
        themeMode = data.themeMode;

  @override
  bool operator ==(Object other) =>
      other is AccountData &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.group == group &&
      other.admin == admin &&
      other.tester == tester &&
      other.themeMode == themeMode;

  @override
  int get hashCode => hashValues(
        id,
        name,
        email,
        group,
        admin,
        tester,
        themeMode,
      );
}

class AccountsService extends ServiceProvider<List<AccountData>> {
  final FirebaseFirestore db;
  AccountData? _me;
  StreamSubscription? _sub;

  AccountsService(this.db) : super([]);

  void subscribe(AccountData me) {
    _me = me;
    if (me.admin) {
      _sub = db.collection('accounts').snapshots().listen(
        (querhSnapshot) {
          final meSnap = querhSnapshot.docs.where(
            (snap) => isValidMyAccount(me, snap),
          );
          if (meSnap.isNotEmpty) {
            notify(querhSnapshot.docs
                .map<AccountData>((snap) => AccountData.fromSnapshot(snap))
                .toList());
          } else {
            _me = null;
            notify([]);
          }
        },
        onError: (Object obj) {
          _me = null;
          unsubscribe();
        },
      );
    } else {
      _sub = db.collection('accounts').doc(me.id).snapshots().listen((snap) {
        if (isValidMyAccount(me, snap)) {
          notify([AccountData.fromSnapshot(snap)]);
        } else {
          notify([]);
          _me = null;
        }
      });
    }
  }

  void unsubscribe() {
    if (_sub != null) {
      _sub!.cancel();
      _sub = null;
      _me = null;
      notify([]);
    }
  }

  bool isValidMyAccount(
    AccountData me,
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) =>
      snap.exists &&
      snap.id == me.id &&
      snap.get('valid') == true &&
      snap.get('deletedAt') == null &&
      snap.get('admin') == true;

  bool get subscribed => _sub != null;

  Future<void> updateAccountProperties(
      String id, Map<String, dynamic> data) async {
    await db.collection('accounts').doc(id).update({
      ...data,
      'updatedBy': _me!.id,
      'updatedAt': DateTime.now(),
    });
  }
}
