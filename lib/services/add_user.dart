import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addUser(name, email, nickname, pic, address) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'nickname': nickname,
    'pic': pic,
    'address': address,
    'name': name,
    'email': email,
    'pts': 0,
    'wallet': 0,
    'phone': '',
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
