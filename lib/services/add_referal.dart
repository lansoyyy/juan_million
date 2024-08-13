import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addReferal(String ref, String type) async {
  final docUser = FirebaseFirestore.instance.collection('Referals').doc(ref);

  final json = {
    'ref': ref,
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'type': type,
  };

  await docUser.set(json);
}
