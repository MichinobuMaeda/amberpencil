// import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import 'service_provider.dart';

class AccountsService extends ServiceProvider<List<Account>> {
  final FirebaseFirestore _db;
  StreamSubscription? _sub;
  Account? _me;

  AccountsService(FirebaseFirestore db)
      : _db = db,
        super('accounts');

  Future<void> subscribe(String uid) async {
    if (_sub != null) {
      return;
    }
    final snap = await _db.collection('accounts').doc(uid).get();
    final Account? me = snap.exists ? Account.fromSnapshot(snap) : null;

    if (!isValidAccount(me)) {
      unsubscribe();
    } else if (me!.admin) {
      _sub = _db.collection('accounts').snapshots().listen(
        (querhSnapshot) {
          final List<Account> accounts = querhSnapshot.docs
              .map((snap) => Account.fromSnapshot(snap))
              .toList();
          final List<Account> newMes =
              accounts.where((item) => isValidMyAccount(item)).toList();
          if (newMes.length == 1) {
            _me = newMes[0];
            update(accounts);
          } else {
            unsubscribe();
          }
        },
        onError: (Object obj) {
          unsubscribe();
        },
      );
    } else {
      _sub = _db.collection('accounts').doc(me.id).snapshots().listen(
        (snap) {
          final Account? newMe =
              snap.exists ? Account.fromSnapshot(snap) : null;
          if (isValidMyAccount(newMe)) {
            update([newMe!]);
          } else {
            unsubscribe();
          }
        },
      );
    }
  }

  void unsubscribe() {
    if (_me != null) {
      _me = null;
      _sub?.cancel();
      _sub = null;
      update([]);
    }
  }

  bool isValidAccount(Account? me) =>
      me != null && me.valid == true && me.deletedAt == null;

  bool isValidMyAccount(Account? me) =>
      isValidAccount(me) &&
      (_me == null || me!.id == _me!.id) &&
      (_me == null || me!.admin == _me!.admin) &&
      (_me == null || me!.tester == _me!.tester);

  Account? get me => _me;

  Future<void> updateAccountProperties(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('accounts').doc(id).update({
      ...data,
      'updatedAt': DateTime.now(),
      'updatedBy': _me!.id,
    });
  }

  Future<void> deleteAccount(
    String id,
  ) async {
    await _db.collection('accounts').doc(id).update({
      'deletedAt': DateTime.now(),
      'deletedBy': _me!.id,
    });
  }
}
