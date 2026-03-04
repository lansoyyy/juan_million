import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addSlots({DateTime? dateTime}) async {
  final docUser = FirebaseFirestore.instance
      .collection('Slots')
      .doc(); // auto-generated ID ensures uniqueness

  final json = {
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'dateTime': dateTime ?? DateTime.now(),
  };

  await docUser.set(json);
  return docUser.id;
}
