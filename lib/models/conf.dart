import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_model.dart';

class Conf extends FirestoreModel {
  static const fieldVersion = 'version';
  static const fieldDataVersion = 'dataVersion';
  static const fieldUrl = 'url';
  static const fieldSeed = 'seed';
  static const fieldInvExpTime = 'invExpTime';
  static const fieldPolicy = 'policy';

  const Conf(DocumentSnapshot<Map<String, dynamic>> snap) : super(snap);

  String get version => getValue<String>(fieldVersion, '');
  int get dataVersion => getValue<int>(fieldDataVersion, 0);
  String get url => getValue<String>(fieldUrl, '');
  String get seed => getValue<String>(fieldSeed, '');
  int get invExpTime => getValue<int>(fieldInvExpTime, 0);
  String get policy => getValue<String>(fieldPolicy, '');

  @override
  List<Object?> get props => super.props
    ..addAll([
      version,
      dataVersion,
      url,
      seed,
      invExpTime,
      policy,
    ]);
}
