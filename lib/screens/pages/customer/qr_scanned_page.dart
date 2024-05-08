import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';

class QRScannedPage extends StatefulWidget {
  String store;
  String pts;

  QRScannedPage({
    super.key,
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
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

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
        this.qrCode = qrCode;
      });

      await FirebaseFirestore.instance
          .collection('Points')
          .doc(qrCode)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'pts': FieldValue.increment(documentSnapshot['pts']),
          });
          await FirebaseFirestore.instance
              .collection('Business')
              .doc(documentSnapshot['uid'])
              .update({
            'pts': FieldValue.increment(-documentSnapshot['pts']),
          });
          await FirebaseFirestore.instance
              .collection('Points')
              .doc(documentSnapshot.id)
              .update({
            'scanned': true,
            'scannedId': FirebaseAuth.instance.currentUser!.uid,
          });
          // Update my points
          // Update business points
        }
      }).whenComplete(() {
        Navigator.pop(context);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(widget.store)
        .snapshots();
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Center(
              child: TextWidget(
                text: 'Points Receipt',
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
                width: 350,
                height: 550,
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
                          text: 'Points Added',
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
                          text:
                              'Your purchase from Juan Store is converted as points',
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
                        text: 'Total Points',
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Regular',
                      ),
                      Center(
                        child: TextWidget(
                          text: '20',
                          fontSize: 48,
                          color: Colors.black,
                          fontFamily: 'Bold',
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget(
                        maxLines: 2,
                        text: 'Points earned from',
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Regular',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: userData,
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
                            dynamic data = snapshot.data;
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      maxRadius: 25,
                                      minRadius: 25,
                                      backgroundImage:
                                          NetworkImage(data['logo']),
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
                                          text: data['name'],
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
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonWidget(
                        radius: 15,
                        color: primary,
                        width: 275,
                        label: 'Done',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerHomeScreen()));
                        },
                      ),
                      TextButton(
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
