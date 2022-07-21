import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conf.dart';
import 'providers.dart';

class ConfRepo {
  final DocumentReference<Map<String, dynamic>> _ref;

  ConfRepo({FirebaseFirestore? instance})
      : _ref = (instance ?? FirebaseFirestore.instance)
            .collection('service')
            .doc('conf');

  void listen(
    WidgetRef ref,
  ) {
    _ref.snapshots().listen(
      (DocumentSnapshot<Map<String, dynamic>> snap) {
        ref.read(confProvider.notifier).state = snap.exists ? Conf(snap) : null;
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('$runtimeType:onError\n$error\n$stackTrace');
      },
    );
  }
}
