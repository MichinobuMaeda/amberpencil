import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_utils.dart';

class Conf extends Equatable {
  final String id;
  final String version;
  final int dataVersion;
  final String url;
  final String seed;
  final int invitationExpirationTime;
  final String policy;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime updatedAt;
  final String? updatedBy;

  const Conf({
    required this.id,
    required this.version,
    required this.dataVersion,
    required this.url,
    required this.seed,
    required this.invitationExpirationTime,
    required this.policy,
    required this.createdAt,
    this.createdBy,
    required this.updatedAt,
    this.updatedBy,
  });

  Conf.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap)
      : id = snap.id,
        version = getFieldValue<String>(snap, 'version') ?? '',
        dataVersion = getFieldValue<int>(snap, 'dataVersion') ?? 0,
        url = getFieldValue<String>(snap, 'url') ?? '',
        seed = getFieldValue<String>(snap, 'seed') ?? '',
        invitationExpirationTime =
            getFieldValue<int>(snap, 'invitationExpirationTime') ?? 3600 * 1000,
        policy = getFieldValue<String>(snap, 'policy') ?? '',
        createdAt = getFieldValue<DateTime>(snap, 'createdAt') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        createdBy = getFieldValue<String>(snap, 'createdBy'),
        updatedAt = getFieldValue<DateTime>(snap, 'updatedAt') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedBy = getFieldValue<String>(snap, 'createdBy');

  @override
  List<Object?> get props => [
        id,
        version,
        dataVersion,
        url,
        seed,
        invitationExpirationTime,
        policy,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];
}
