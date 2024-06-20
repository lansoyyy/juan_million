import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addSlots() async {
  final docUser = FirebaseFirestore.instance
      .collection('Slots')
      .doc(DateTime.now().toString());

  final json = {
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
  return docUser.id;
}
