import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addBusiness(
    name, email, logo, address, desc, clarification, representative) async {
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
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'ptsreceive': 0,
    'ptsconversion': 0,
    'logo': logo,
    'address': address,
    'desc': desc,
    'clarification': clarification,
    'representative': representative,
  };

  await docUser.set(json);
}
