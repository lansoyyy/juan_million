import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addCashier(name, pin) async {
  final docUser = FirebaseFirestore.instance.collection('Cashiers').doc(pin);

  final json = {
    'name': name,
    'pin': pin,
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
  return docUser.id;
}
