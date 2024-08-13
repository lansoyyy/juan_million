import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addReferal(String ref) async {
  final docUser = FirebaseFirestore.instance
      .collection('Referals')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {'ref': ref, 'uid': FirebaseAuth.instance.currentUser!.uid};

  await docUser.set(json);
}
