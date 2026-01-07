import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/screens/pages/customer/qr_scanner_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class QRScannedPage extends StatefulWidget {
  String store;
  String pts;

  bool? inuser;
  bool? fromWallet;
  bool? fromScan;

  QRScannedPage({
    super.key,
    this.fromWallet = false,
    this.fromScan = false,
    this.inuser = true,
    required this.pts,
    required this.store,
  });

  @override
  State<QRScannedPage> createState() => _QRScannedPageState();
}

class _QRScannedPageState extends State<QRScannedPage> {
  String qrCode = 'Unknown';

  Future<void> scanQRCode() async {
    try {
      // Navigate to a new screen for QR scanning
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QRScannerScreen(),
        ),
      );

      if (result == null) {
        // User cancelled the scan
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        qrCode = result;
      });

      final pointsRef =
          FirebaseFirestore.instance.collection('Points').doc(result);
      final pointsSnap = await pointsRef.get();

      if (!pointsSnap.exists) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final Map<String, dynamic>? data = pointsSnap.data();
      if (data == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final bool alreadyScanned = data['scanned'] == true;
      if (alreadyScanned) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        showToast('This QR code was already claimed', context: context);
        return;
      }

      final dynamic rawPts = data['pts'];
      final int ptsValue = rawPts is num ? rawPts.toInt() : 0;
      final String businessId = data['uid']?.toString() ?? '';
      if (ptsValue <= 0 || businessId.isEmpty) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final businessRef =
          FirebaseFirestore.instance.collection('Business').doc(businessId);
      final communityRef = FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet');

      final batch = FirebaseFirestore.instance.batch();
      batch.update(userRef, {
        'pts': FieldValue.increment(ptsValue),
      });
      batch.update(businessRef, {
        'pts': FieldValue.increment(-ptsValue),
      });
      batch.update(pointsRef, {
        'scanned': true,
        'scannedId': userId,
      });
      batch.update(communityRef, {
        'pts': FieldValue.increment(ptsValue),
      });
      await batch.commit();

      if (!mounted) return;
      setState(() {
        widget.pts = ptsValue.toString();
        widget.store = businessId;
      });

      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      showToast('Failed to scan QR code', context: context);
    } catch (_) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      showToast('Scan failed. Please try again.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = (size.width - 40).clamp(280.0, 350.0).toDouble();
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(widget.store)
        .snapshots();
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => widget.inuser!
                          ? const CustomerHomeScreen()
                          : const BusinessHomeScreen()));
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              Center(
                child: TextWidget(
                  text: widget.fromWallet!
                      ? 'Transfer Receipt'
                      : 'Points Receipt',
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'Bold',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: blue,
                          size: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: TextWidget(
                            text: widget.fromWallet!
                                ? widget.fromScan!
                                    ? 'Points Transfer'
                                    : 'Wallet Transfer'
                                : 'Points Added',
                            fontSize: 24,
                            color: Colors.black,
                            fontFamily: 'Bold',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 250,
                          child: TextWidget(
                            maxLines: 2,
                            text: widget.fromWallet!
                                ? 'You transfer Points'
                                : 'Your purchase from Juan Store is converted as points',
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Regular',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextWidget(
                          maxLines: 2,
                          text: widget.fromWallet!
                              ? 'Transferred'
                              : 'Total Points',
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Regular',
                        ),
                        Center(
                          child: TextWidget(
                            text: widget.pts,
                            fontSize: 48,
                            color: Colors.black,
                            fontFamily: 'Bold',
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.fromWallet!
                            ? const SizedBox()
                            : !widget.inuser!
                                ? const SizedBox()
                                : TextWidget(
                                    maxLines: 2,
                                    text: 'Points earned from',
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Regular',
                                  ),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.fromWallet!
                            ? const SizedBox()
                            : !widget.inuser!
                                ? const SizedBox()
                                : StreamBuilder<DocumentSnapshot>(
                                    stream: userData,
                                    builder: (context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: Text('Loading'));
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child:
                                                Text('Something went wrong'));
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final snap = snapshot.data!;
                                      if (!snap.exists) {
                                        return const SizedBox();
                                      }
                                      final businessData = snap.data();
                                      if (businessData is! Map) {
                                        return const SizedBox();
                                      }
                                      final String name =
                                          businessData['name']?.toString() ??
                                              'Business';
                                      final String logoUrl =
                                          businessData['logo']?.toString() ??
                                              '';
                                      return Container(
                                        width: 275,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                maxRadius: 25,
                                                minRadius: 25,
                                                backgroundImage:
                                                    logoUrl.isNotEmpty
                                                        ? NetworkImage(logoUrl)
                                                        : null,
                                                child: logoUrl.isEmpty
                                                    ? const Icon(Icons.store)
                                                    : null,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: name,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontFamily: 'Bold',
                                                  ),
                                                  TextWidget(
                                                    text: DateFormat.yMMMd()
                                                        .add_jm()
                                                        .format(DateTime.now()),
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontFamily: 'Regular',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                        widget.fromScan!
                            ? StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.store)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: Text('Loading'));
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Something went wrong'));
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final snap = snapshot.data!;
                                  if (!snap.exists) {
                                    return const SizedBox();
                                  }
                                  final userData = snap.data();
                                  if (userData is! Map) {
                                    return const SizedBox();
                                  }
                                  final String name =
                                      userData['name']?.toString() ?? 'User';
                                  final String picUrl =
                                      userData['pic']?.toString() ?? '';
                                  return SizedBox(
                                    width: 300,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            maxRadius: 40,
                                            minRadius: 40,
                                            backgroundImage: picUrl.isNotEmpty
                                                ? NetworkImage(picUrl)
                                                : null,
                                            child: picUrl.isEmpty
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          TextWidget(
                                            text: name,
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontFamily: 'Bold',
                                          ),
                                          TextWidget(
                                            text: DateFormat.yMMMd()
                                                .add_jm()
                                                .format(DateTime.now()),
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontFamily: 'Regular',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        ButtonWidget(
                          radius: 15,
                          color: primary,
                          width: 275,
                          label: 'Done',
                          onPressed: () {
                            if (widget.inuser!) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerHomeScreen()));
                            } else {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BusinessHomeScreen()));
                            }
                          },
                        ),
                        widget.fromWallet!
                            ? const SizedBox()
                            : !widget.inuser!
                                ? const SizedBox()
                                : TextButton(
                                    onPressed: () {
                                      scanQRCode();
                                    },
                                    child: TextWidget(
                                      text: 'Scan Again',
                                      fontSize: 14,
                                      color: primary,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
