import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addUser(name, email) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'email': email,
    'pts': 0,
    'wallet': 0,
    'phone': '',
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
