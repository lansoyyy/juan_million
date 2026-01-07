import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> addWallet(pts, from, uid, String type, String cashier) async {
  final docUser = FirebaseFirestore.instance.collection('Wallets').doc();

  final json = {
    'pts': pts,
    'from': from,
    'uid': uid,
    'id': docUser.id,
    'dateTime': DateTime.now(),
    'type': type,
    'cashier': cashier,
  };

  await docUser.set(json);
  return docUser.id;
}
