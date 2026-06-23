import 'package:cloud_firestore/cloud_firestore.dart';

class AffiliateResolution {
  final String businessUid;
  final String businessName;

  AffiliateResolution({
    required this.businessUid,
    required this.businessName,
  });
}

String normalizeAffiliateInput(String raw) {
  var value = raw.trim();
  value = value.replaceAll(
    RegExp(r'\s*\(Referral Code\)\s*$', caseSensitive: false),
    '',
  );
  return value.trim();
}

Future<AffiliateResolution?> _fromBusinessDoc(
  DocumentSnapshot<Map<String, dynamic>> doc,
) async {
  if (!doc.exists) return null;
  final data = doc.data();
  return AffiliateResolution(
    businessUid: doc.id,
    businessName: data?['name']?.toString() ?? 'Business',
  );
}

Future<AffiliateResolution?> _fromReferalsData(
  Map<String, dynamic> data,
) async {
  final type = data['type']?.toString() ?? '';
  if (type.toLowerCase() != 'business') return null;

  final uid = data['uid']?.toString() ?? '';
  if (uid.isEmpty) return null;

  final biz = await FirebaseFirestore.instance
      .collection('Business')
      .doc(uid)
      .get();
  return _fromBusinessDoc(biz);
}

Future<AffiliateResolution?> resolveAffiliateBusiness(String rawInput) async {
  final input = normalizeAffiliateInput(rawInput);
  if (input.isEmpty) return null;

  final byRef = await FirebaseFirestore.instance
      .collection('Business')
      .where('ref', isEqualTo: input)
      .limit(1)
      .get();
  if (byRef.docs.isNotEmpty) {
    return _fromBusinessDoc(byRef.docs.first);
  }

  final byUid =
      await FirebaseFirestore.instance.collection('Business').doc(input).get();
  final byUidResult = await _fromBusinessDoc(byUid);
  if (byUidResult != null) return byUidResult;

  final refSnap = await FirebaseFirestore.instance
      .collection('Referals')
      .where('ref', isEqualTo: input)
      .limit(1)
      .get();
  if (refSnap.docs.isNotEmpty) {
    return _fromReferalsData(refSnap.docs.first.data());
  }

  final legacyRef =
      await FirebaseFirestore.instance.collection('Referals').doc(input).get();
  if (legacyRef.exists) {
    final data = legacyRef.data();
    if (data != null) {
      return _fromReferalsData(data);
    }
  }

  return null;
}
