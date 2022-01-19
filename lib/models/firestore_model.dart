import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class FirestoreModel extends Equatable {
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldCreatedBy = 'createdBy';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldUpdatedBy = 'updatedBy';
  static const String fieldDeletedAt = 'deletedAt';
  static const String fieldDeletedBy = 'deletedBy';

  final DocumentSnapshot<Map<String, dynamic>> snap;

  const FirestoreModel(this.snap);

  String get id => snap.id;
  DateTime? get createdAt => getValue<DateTime?>(fieldCreatedAt, null);
  String? get createdBy => getValue<String?>(fieldCreatedBy, null);
  DateTime? get updatedAt => getValue<DateTime?>(fieldUpdatedAt, null);
  String? get updatedBy => getValue<String?>(fieldUpdatedBy, null);
  DateTime? get deletedAt => getValue<DateTime?>(fieldDeletedAt, null);
  String? get deletedBy => getValue<String?>(fieldDeletedBy, null);

  Type getValue<Type>(String key, Type defaultValue) {
    try {
      final val = snap.get(key);
      if (Type == DateTime) {
        return val is Timestamp ? (val.toDate() as Type) : defaultValue;
      } else {
        return val is Type ? val : defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  List<Object?> get props => [
        fieldCreatedAt,
        fieldCreatedBy,
        fieldUpdatedAt,
        fieldUpdatedBy,
        fieldDeletedAt,
        fieldDeletedBy,
      ];
}
