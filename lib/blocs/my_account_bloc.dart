// import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/auth_user.dart';
import '../models/account.dart';

class MyAccountStatus extends Equatable {
  final AuthUser? authUser;
  final Account? me;

  const MyAccountStatus(this.authUser, this.me);

  @override
  List<Object?> get props => [authUser, me];
}

abstract class MeEvent {}

class OnAuthUserUpdated extends MeEvent {
  final AuthUser? authUser;

  OnAuthUserUpdated(this.authUser);
}

class OnAccountsUpdated extends MeEvent {
  final List<Account>? accounts;

  OnAccountsUpdated(this.accounts);
}

class OnSingOutRequired extends MeEvent {}

class MyAccountBloc extends Bloc<MeEvent, MyAccountStatus> {
  final FirebaseFirestore _db;

  MyAccountBloc({
    FirebaseFirestore? db,
  })  : _db = db ?? FirebaseFirestore.instance,
        super(const MyAccountStatus(null, null)) {
    on<OnAuthUserUpdated>((event, emit) async {
      validateAndEmitState(
        event.authUser,
        event.authUser == null
            ? null
            : event.authUser!.uid == state.me?.id
                ? state.me
                : await restoreMe(_db, event.authUser!.uid),
        emit,
      );
    });

    on<OnAccountsUpdated>((event, emit) {
      try {
        validateAndEmitState(
          state.authUser,
          state.authUser == null
              ? null
              : (event.accounts ?? []).singleWhere(
                  (account) => account.id == state.authUser?.uid,
                ),
          emit,
        );
      } catch (e) {
        emit(const MyAccountStatus(null, null));
      }
    });

    on<OnSingOutRequired>((event, emit) async {
      emit(const MyAccountStatus(null, null));
    });
  }

  void validateAndEmitState(
    AuthUser? authUser,
    Account? me,
    Emitter emit,
  ) {
    if (validateState(authUser, me)) {
      emit(MyAccountStatus(authUser, me));
    } else {
      emit(const MyAccountStatus(null, null));
    }
  }

  bool validateState(
    AuthUser? authUser,
    Account? me,
  ) =>
      (authUser == null && me == null) ||
      (authUser?.uid == me?.id &&
          (me?.valid ?? false) &&
          me?.deletedAt == null &&
          (state.me == null ||
              (state.me?.admin == me?.admin &&
                  state.me?.tester == me?.tester)));

  Future<Account?> restoreMe(
    FirebaseFirestore db,
    String uid,
  ) async {
    final snap = await db.collection('accounts').doc(uid).get();
    return snap.exists ? Account(snap) : null;
  }
}
