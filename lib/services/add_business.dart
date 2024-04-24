import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addBusiness(name, email) async {
  final docUser = FirebaseFirestore.instance
      .collection('Business')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'email': email,
    'pts': 0,
    'wallet': 0,
    'inventory': 0,
    'phone': '',
    'ptsConversion': 0,
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
