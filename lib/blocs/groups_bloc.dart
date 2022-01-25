import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/account.dart';
import '../models/group.dart';
import '../utils/firestore_deligate.dart';

abstract class GroupsEvent {}

class GroupsSnapshot extends GroupsEvent {
  final QuerySnapshot<Map<String, dynamic>> querySnap;

  GroupsSnapshot(this.querySnap);
}

class GroupsListenError extends GroupsEvent {}

class GroupsSubscribed extends GroupsEvent {
  final Account me;

  GroupsSubscribed(this.me);
}

class GroupsUnsubscribed extends GroupsEvent {}

class GroupsChanged extends GroupsEvent {
  final String id;
  final String field;
  final String value;

  GroupsChanged(this.id, this.field, this.value);
}

class GroupsBloc extends Bloc<GroupsEvent, List<Group>> {
  final FireStorereDeligate _firestore;
  late CollectionReference<Map<String, dynamic>> _ref;

  GroupsBloc({
    FirebaseFirestore? db,
  })  : _firestore = FireStorereDeligate(db ?? FirebaseFirestore.instance),
        super([]) {
    _ref = _firestore.db.collection('groups');

    on<GroupsSnapshot>(
      (event, emit) {
        emit(event.querySnap.docs.map((snap) => Group(snap)).toList());
      },
    );

    on<GroupsListenError>((event, emit) => emit([]));

    on<GroupsSubscribed>((event, emit) {
      _firestore.subscribe(event.me);
      _firestore.listen(
        (event.me.admin
                ? _ref
                : _ref.where(Group.fieldAccounts, arrayContains: event.me.id))
            .snapshots()
            .listen(
          (querySnap) {
            add(GroupsSnapshot(querySnap));
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('$runtimeType:onError\n$error\n$stackTrace');
            add(GroupsListenError());
          },
        ),
      );
    });

    on<GroupsUnsubscribed>((event, emit) async {
      await _firestore.unsubscribe();
      await _firestore.cancel();
      emit([]);
    });

    on<GroupsChanged>((event, emit) async {
      _firestore.updateDocument(
        _ref.doc(event.id),
        {event.field: event.value},
      );
    });
  }
}
