import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<void> useFirebaseEmulators(
  String version,
  FirebaseAuth auth,
  FirebaseFirestore db,
  FirebaseFunctions functions,
  firebase_storage.FirebaseStorage storage,
) async {
  if (version == "0.0.0+0") {
    debugPrint('Use emulators.');
    try {
      await auth.useAuthEmulator('localhost', 9099);
      db.useFirestoreEmulator('localhost', 8080);
      functions.useFunctionsEmulator('localhost', 5001);
      await storage.useStorageEmulator('localhost', 9199);
    } catch (e) {
      debugPrint('Firestore has already been started.');
    }
  }
}
