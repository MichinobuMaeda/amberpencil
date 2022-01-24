import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';
import '../utils/firestore_deligate.dart';

abstract class AccountsEvent {}

class AccountsSnapshot extends AccountsEvent {
  final List<DocumentSnapshot<Map<String, dynamic>>> docs;

  AccountsSnapshot(this.docs);
}

class AccountsListenError extends AccountsEvent {}

class AccountsSubscribed extends AccountsEvent {
  final Account me;

  AccountsSubscribed(this.me);
}

class AccountsUnsubscribed extends AccountsEvent {}

class MyAccountChanged extends AccountsEvent {
  final String field;
  final String value;
  final VoidCallback onError;

  MyAccountChanged(this.field, this.value, this.onError);
}

class AccountChanged extends AccountsEvent {
  final String id;
  final String field;
  final String value;
  final VoidCallback onError;

  AccountChanged(this.id, this.field, this.value, this.onError);
}

class AccountDeleted extends AccountsEvent {
  final String id;
  final VoidCallback onError;

  AccountDeleted(this.id, this.onError);
}

class AccountsBloc extends Bloc<AccountsEvent, List<Account>> {
  final FireStorereDeligate _firestore;
  late CollectionReference<Map<String, dynamic>> _ref;

  AccountsBloc({
    FirebaseFirestore? db,
  })  : _firestore = FireStorereDeligate(db ?? FirebaseFirestore.instance),
        super([]) {
    _ref = _firestore.db.collection('accounts');

    on<AccountsSnapshot>(
      (event, emit) {
        emit(event.docs.map((snap) => Account(snap)).toList());
      },
    );

    on<AccountsListenError>((event, emit) => emit([]));

    on<AccountsSubscribed>((event, emit) {
      _firestore.subscribe(event.me);
      _firestore.listen(
        event.me.admin
            ? _ref.snapshots().listen(
                (querySnap) {
                  add(AccountsSnapshot(querySnap.docs));
                },
                onError: onListenError,
              )
            : _ref.doc(event.me.id).snapshots().listen(
                (snap) {
                  add(AccountsSnapshot(snap.exists ? [snap] : []));
                },
                onError: onListenError,
              ),
      );
    });

    on<AccountsUnsubscribed>((event, emit) async {
      debugPrint('$runtimeType:unsubscribe');
      _firestore.unsubscribe();
      _firestore.cancel();
    });

    on<MyAccountChanged>((event, emit) async {
      try {
        await _firestore.updateDocument(
          _ref.doc(_firestore.me?.id),
          {event.field: event.value},
        );
      } catch (e, s) {
        debugPrint('/n$runtimeType:on<MyAccountChanged>/n$e/n$s/n');
        event.onError();
      }
    });

    on<AccountChanged>((event, emit) async {
      try {
        await _firestore.updateDocument(
          _ref.doc(event.id),
          {event.field: event.value},
        );
      } catch (e, s) {
        debugPrint('/n$runtimeType:on<AccountChanged>/n$e/n$s/n');
        event.onError();
      }
    });

    on<AccountDeleted>((event, emit) async {
      try {
        await _firestore.deleteDocument(
          _ref.doc(event.id),
        );
      } catch (e, s) {
        debugPrint('/n$runtimeType:on<AccountDeleted>/n$e/n$s/n');
        event.onError();
      }
    });
  }

  void onListenError(Object error, StackTrace stackTrace) {
    debugPrint('$runtimeType:onError\n$error\n$stackTrace');
    add(AccountsListenError());
  }

  Future<Account?> restoreMe(String uid) async {
    final snap = await _ref.doc(uid).get();
    return snap.exists ? Account(snap) : null;
  }
}
