import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/account.dart';
import '../models/conf.dart';
import '../utils/firestore_deligate.dart';

abstract class ConfEvent {}

class ConfListenStart extends ConfEvent {}

class ConfSnapshot extends ConfEvent {
  final DocumentSnapshot<Map<String, dynamic>> snap;

  ConfSnapshot(this.snap);
}

class ConfListenError extends ConfEvent {}

class ConfSubscribed extends ConfEvent {
  final Account me;

  ConfSubscribed(this.me);
}

class ConfUnsubscribed extends ConfEvent {}

class ConfChangedPolicy extends ConfEvent {
  final String value;
  final VoidCallback onError;

  ConfChangedPolicy(this.value, this.onError);
}

class ConfBloc extends Bloc<ConfEvent, Conf?> {
  final FireStorereDeligate _firestore;
  late DocumentReference<Map<String, dynamic>> _ref;

  ConfBloc({
    FirebaseFirestore? db,
  })  : _firestore = FireStorereDeligate(db ?? FirebaseFirestore.instance),
        super(null) {
    _ref = _firestore.db.collection('service').doc('conf');

    on<ConfListenStart>((event, emit) {
      _firestore.listen(
        _ref.snapshots().listen(
          (DocumentSnapshot<Map<String, dynamic>> snap) {
            add(ConfSnapshot(snap));
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('$runtimeType:onError\n$error\n$stackTrace');
            add(ConfListenError());
          },
        ),
      );
    });

    on<ConfSnapshot>(
      (event, emit) {
        Conf? value = event.snap.exists ? Conf(event.snap) : null;
        emit(value);
      },
    );

    on<ConfListenError>((event, emit) => emit(null));

    on<ConfSubscribed>((event, emit) => _firestore.subscribe(event.me));

    on<ConfUnsubscribed>((event, emit) => _firestore.unsubscribe());

    on<ConfChangedPolicy>(
      (event, emit) async {
        try {
          await _firestore.updateDocument(_ref, {
            Conf.fieldPolicy: event.value,
          });
        } catch (e, s) {
          debugPrint('\non<ConfChangedPolicy>\n$e\n$s\n');
          event.onError();
        }
      },
    );
  }
}
