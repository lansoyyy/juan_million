import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addBusiness(name, email, logo, address, desc, clarification,
    representative, ref) async {
  Map<String, dynamic> defaults = <String, dynamic>{};
  try {
    final defaultsDoc = await FirebaseFirestore.instance
        .collection('AdminConfig')
        .doc('SignupDefaults')
        .get();
    defaults = defaultsDoc.data() ?? <String, dynamic>{};
  } catch (_) {}

  final int initialPts = (defaults['businessInitialPts'] is num)
      ? (defaults['businessInitialPts'] as num).toInt()
      : 0;
  final int initialWallet = (defaults['businessInitialWallet'] is num)
      ? (defaults['businessInitialWallet'] as num).toInt()
      : 0;
  final int initialInventory = (defaults['businessInitialInventory'] is num)
      ? (defaults['businessInitialInventory'] as num).toInt()
      : 0;
  final double initialPtsConversion =
      (defaults['businessInitialPtsConversion'] is num)
          ? (defaults['businessInitialPtsConversion'] as num).toDouble()
          : 0;
  final bool initialVerified = defaults['businessInitialVerified'] == true;

  final docUser = FirebaseFirestore.instance
      .collection('Business')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'email': email,
    'pts': initialPts,
    'wallet': initialWallet,
    'inventory': initialInventory,
    'phone': '',
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'ptsreceive': 0,
    'ptsconversion': initialPtsConversion,
    'logo': logo,
    'address': address,
    'desc': desc,
    'clarification': clarification,
    'representative': representative,
    'verified': initialVerified,
    'packagePayment': 0,
    'packageWallet': 0,
    'ref': ref,
  };

  await docUser.set(json);
}
