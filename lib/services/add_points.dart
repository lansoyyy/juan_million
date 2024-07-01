import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> addPoints(pts, qty, cashier) async {
  final docUser = FirebaseFirestore.instance.collection('Points').doc();

  final json = {
    'pts': pts,
    'qty': qty,
    'cashier': cashier,
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'id': docUser.id,
    'scanned': false,
    'scannedId': '',
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
  return docUser.id;
}
