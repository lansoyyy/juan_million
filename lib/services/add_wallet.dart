import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addWallet(pts, from, id, String type) async {
  final docUser = FirebaseFirestore.instance.collection('Wallets').doc();

  final json = {
    'pts': pts,
    'from': from,
    'uid': id,
    'id': docUser.id,
    'dateTime': DateTime.now(),
    'type': type,
  };

  await docUser.set(json);
  return docUser.id;
}
