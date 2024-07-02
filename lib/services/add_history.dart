import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addHistory(String name, String uid) async {
  final docUser = FirebaseFirestore.instance
      .collection('History')
      .doc(DateTime.now().toString());

  final json = {
    'uid': uid,
    'name': name,
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
  return docUser.id;
}
