import 'package:cloud_firestore/cloud_firestore.dart';

dynamic getFieldValue<Type>(
  DocumentSnapshot<Map<String, dynamic>> snap,
  String key,
) {
  try {
    final val = snap.get(key);
    if (Type == DateTime) {
      return val is Timestamp
          ? DateTime.fromMillisecondsSinceEpoch(
              val.seconds * 1000 + val.nanoseconds ~/ (1000 * 1000),
            )
          : null;
    } else {
      return val is Type ? val : null;
    }
  } catch (e) {
    return null;
  }
}
