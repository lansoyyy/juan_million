import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/business/cashier_screen.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/business/payments_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/dragonpay_screen.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

import '../widgets/button_widget.dart';
import '../widgets/textfield_widget.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  final pin = TextEditingController();

  final amount = TextEditingController();

  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> reauthenticateUser(String email, String password) async {
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

    try {
      await user.reauthenticateWithCredential(credential);
      print("Re-authentication successful");

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
    } on FirebaseAuthException catch (e) {
      showToast('Unauthorized to access this feature!');
      print("Error: ${e.message}");
    }
  }

  String qrCode = 'Unknown';

  Future<void> scanQRCode(int transferredPts, String cashier) async {
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

      Navigator.pop(context);
      setState(() {
        this.qrCode = qrCode;
      });

      if (qrCode != '-1') {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(qrCode)
            .get();
        await FirebaseFirestore.instance
            .collection('Business')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          print('Pts ${documentSnapshot['pts']}');
          print('Pts $qrCode');
          if (documentSnapshot['pts'] >= transferredPts) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(qrCode)
                .update({
              'pts': FieldValue.increment(transferredPts),
            });
            await FirebaseFirestore.instance
                .collection('Business')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'pts': FieldValue.increment(-transferredPts),
            });

            await FirebaseFirestore.instance
                .collection('Community Wallet')
                .doc('wallet')
                .update({
              // 'wallet': FieldValue.increment(total),
              'pts': FieldValue.increment(transferredPts),
            });
            // Update my points
            // Update business points
          } else {
            showToast('Your wallet balance is not enough');
          }
        }).whenComplete(() {
          addPoints(transferredPts, 1, cashier, 'Points received by member',
              documentSnapshot.id);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QRScannedPage(
                    fromScan: true,
                    inuser: false,
                    fromWallet: true,
                    pts: transferredPts.toString(),
                    store: qrCode,
                  )));
        });
      } else {
        Navigator.pop(context);
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: userData,
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading'));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  dynamic mydata = snapshot.data;
                  return Column(
                    children: [
                      // Enhanced header with better visual hierarchy
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [blue, Colors.blue.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 15),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Hello ka-Juan!',
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: 'Medium',
                                        ),
                                        const SizedBox(height: 5),
                                        TextWidget(
                                          text:
                                              mydata['name'] ?? 'Business User',
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontFamily: 'Regular',
                                        ),
                                      ],
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              TextWidget(
                                                                text: 'Scan QR',
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'Bold',
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              IconButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .close),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          TextFieldWidget(
                                                            showEye: true,
                                                            isObscure: true,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            hint: 'PIN Code',
                                                            borderColor: blue,
                                                            radius: 12,
                                                            width: 350,
                                                            prefixIcon:
                                                                Icons.lock,
                                                            isRequred: false,
                                                            controller: pin,
                                                            label: 'PIN Code',
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          ButtonWidget(
                                                            label: 'Confirm',
                                                            onPressed:
                                                                () async {
                                                              DocumentSnapshot
                                                                  doc =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Cashiers')
                                                                      .doc(pin
                                                                          .text)
                                                                      .get()
                                                                      .whenComplete(
                                                                          () {
                                                                Navigator.pop(
                                                                    context);
                                                              });

                                                              if (doc.exists) {
                                                                if (mydata[
                                                                        'pts'] >
                                                                    1) {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        title:
                                                                            TextWidget(
                                                                          text:
                                                                              'Input Amount Purchased',
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'Regular',
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        content:
                                                                            StatefulBuilder(builder:
                                                                                (context, setState) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 20, bottom: 20),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                TextFieldWidget(
                                                                                  controller: amount,
                                                                                  label: 'Amount',
                                                                                  inputType: const TextInputType.numberWithOptions(decimal: true),
                                                                                ),
                                                                                const SizedBox(height: 20),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                  children: [
                                                                                    TextButton(
                                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                                      child: TextWidget(
                                                                                        text: 'Close',
                                                                                        fontSize: 16,
                                                                                        color: Colors.grey,
                                                                                        fontFamily: 'Medium',
                                                                                      ),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                        scanQRCode(
                                                                                          ((double.parse(amount.text) * mydata['ptsconversion']) * 0.01).toInt(),
                                                                                          doc['name'],
                                                                                        );
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: blue,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                      ),
                                                                                      child: TextWidget(
                                                                                        text: 'Continue',
                                                                                        fontSize: 16,
                                                                                        color: Colors.white,
                                                                                        fontFamily: 'Bold',
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  showToast(
                                                                      "You don't have enough points.");
                                                                }
                                                              } else {
                                                                showToast(
                                                                    'PIN Code does not exist!');
                                                              }

                                                              pin.clear();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.qr_code,
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const CashiersScreen()));
                                            },
                                            icon: const Icon(
                                              Icons.groups_2_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SettingsPage()));
                                            },
                                            icon: const Icon(
                                              Icons.settings,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Enhanced wallet balance display
                      Container(
                        height: 220,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: PageView.builder(
                          itemCount: 3,
                          controller: PageController(viewportFraction: 0.85),
                          onPageChanged: (index) {},
                          itemBuilder: (context, index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: index == 0
                                      ? [blue, Colors.blue.shade800]
                                      : index == 1
                                          ? [primary, Colors.green.shade800]
                                          : [
                                              Colors.yellow,
                                              Colors.yellow.shade600
                                            ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (index == 0) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PointsPage()));
                                  } else if (index == 1) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WalletPage()));
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const InventoryPage()));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: index == 0
                                                ? 'Points Inventory'
                                                : index == 1
                                                    ? 'E Wallet'
                                                    : 'Transaction History',
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontFamily: 'Medium',
                                          ),
                                          Icon(
                                            index == 0
                                                ? Icons.stars_rounded
                                                : index == 1
                                                    ? Icons
                                                        .account_balance_wallet_rounded
                                                    : Icons.history_rounded,
                                            color: Colors.white70,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Points')
                                              .where('uid',
                                                  isEqualTo: mydata.id)
                                              .where('scanned', isEqualTo: true)
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              print(snapshot.error);
                                              return const Center(
                                                  child: Text('Error'));
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: Colors.white,
                                              ));
                                            }

                                            final data = snapshot.requireData;
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextWidget(
                                                  text: index == 0
                                                      ? '${mydata['pts']}'
                                                      : index == 1
                                                          ? AppConstants
                                                              .formatNumberWithPeso(
                                                                  mydata[
                                                                      'wallet'])
                                                          : data.docs.length
                                                              .toString(),
                                                  fontFamily: 'Bold',
                                                  fontSize: 40,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 5),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: TextWidget(
                                                    text: index == 0
                                                        ? 'pts'
                                                        : index == 1
                                                            ? ''
                                                            : 'txns',
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                    fontFamily: 'Regular',
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWidget(
                                            text: 'Tap to view details',
                                            fontSize: 12,
                                            color: Colors.white70,
                                            fontFamily: 'Regular',
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white70,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Enhanced wallet actions section
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextWidget(
                                  text: 'Reload',
                                  fontSize: 18,
                                  fontFamily: 'Bold',
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentsPage(),
                                      ),
                                    );
                                  },
                                  child: TextWidget(
                                    text: 'View Status',
                                    fontSize: 14,
                                    color: blue,
                                    fontFamily: 'Medium',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Card(
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.blue.shade50
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 160,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Image.asset(
                                                'assets/images/Juan4All 2.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: 'Reload your POINTS!',
                                                fontSize: 18,
                                                color: blue,
                                                fontFamily: 'Bold',
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          blue.withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: TextWidget(
                                                      text: 'P1.00 per 1 Point',
                                                      fontSize: 12,
                                                      color: blue,
                                                      fontFamily: 'Medium',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              ButtonWidget(
                                                radius: 10,
                                                height: 35,
                                                width: 100,
                                                fontSize: 14,
                                                label: 'Reload Now',
                                                onPressed: () async {
                                                  QuerySnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Cashiers')
                                                          .where('uid',
                                                              isEqualTo:
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                          .get();

                                                  if (snapshot
                                                      .docs.isNotEmpty) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    TextWidget(
                                                                      text:
                                                                          'Enter PIN',
                                                                      fontSize:
                                                                          18,
                                                                      fontFamily:
                                                                          'Bold',
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .close),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                TextFieldWidget(
                                                                  showEye: true,
                                                                  isObscure:
                                                                      true,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                  hint:
                                                                      'PIN Code',
                                                                  borderColor:
                                                                      blue,
                                                                  radius: 12,
                                                                  width: 350,
                                                                  prefixIcon:
                                                                      Icons
                                                                          .lock,
                                                                  isRequred:
                                                                      false,
                                                                  controller:
                                                                      pin,
                                                                  label:
                                                                      'PIN Code',
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                ButtonWidget(
                                                                  label:
                                                                      'Confirm',
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);

                                                                    DocumentSnapshot doc = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Cashiers')
                                                                        .doc(pin
                                                                            .text)
                                                                        .get();

                                                                    if (doc
                                                                        .exists) {
                                                                      reloadPointsDialog(
                                                                          doc['name']);
                                                                    } else {
                                                                      showToast(
                                                                          'PIN Code does not exist!');
                                                                    }
                                                                    pin.clear();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    showToast(
                                                        'Please register your authorized user account');
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Enhanced transaction history section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextWidget(
                                      text: 'Recent Activity',
                                      fontSize: 18,
                                      fontFamily: 'Bold',
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const InventoryPage()));
                                      },
                                      child: TextWidget(
                                        text: 'View All',
                                        fontSize: 14,
                                        color: blue,
                                        fontFamily: 'Medium',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Points')
                                        .where('uid',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        // .where('scanned', isEqualTo: true)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        print(snapshot.error);
                                        return const Center(
                                            child: Text('Error'));
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.only(top: 50),
                                          child: Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.black,
                                          )),
                                        );
                                      }

                                      final data = snapshot.requireData;
                                      return data.docs.isEmpty
                                          ? Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.history,
                                                      color: Colors.grey[400],
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    TextWidget(
                                                      text:
                                                          'No Recent Activity',
                                                      fontSize: 14,
                                                      fontFamily: 'Regular',
                                                      color: Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: 180,
                                              child: ListView.builder(
                                                itemCount: data.docs.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Show transaction details
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        TextWidget(
                                                                          text:
                                                                              'Transaction Details',
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'Bold',
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        IconButton(
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                          icon:
                                                                              const Icon(Icons.close),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        TextWidget(
                                                                          text: data
                                                                              .docs[index]['pts']
                                                                              .toString(),
                                                                          fontSize:
                                                                              38,
                                                                          fontFamily:
                                                                              'Bold',
                                                                          color:
                                                                              blue,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                5),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 8),
                                                                          child:
                                                                              TextWidget(
                                                                            text:
                                                                                'pts',
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                blue,
                                                                            fontFamily:
                                                                                'Regular',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            15),
                                                                    TextWidget(
                                                                      text: DateFormat
                                                                              .yMMMd()
                                                                          .add_jm()
                                                                          .format(data
                                                                              .docs[index]['dateTime']
                                                                              .toDate()),
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          'Medium',
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    ButtonWidget(
                                                                      label:
                                                                          'Close',
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Card(
                                                        elevation: 8,
                                                        shadowColor: Colors
                                                            .black
                                                            .withOpacity(0.1),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        color: Colors.white,
                                                        child: SizedBox(
                                                          width: 160,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: blue
                                                                        .withOpacity(
                                                                            0.1),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .stars_rounded,
                                                                    color: blue,
                                                                    size: 24,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 15),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    TextWidget(
                                                                      text: data
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'pts']
                                                                          .toString(),
                                                                      fontSize:
                                                                          32,
                                                                      fontFamily:
                                                                          'Bold',
                                                                      color:
                                                                          blue,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          TextWidget(
                                                                        text:
                                                                            'pts',
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Bold',
                                                                        color:
                                                                            blue,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                TextWidget(
                                                                  text: DateFormat
                                                                          .MMMd()
                                                                      .format(data
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'dateTime']
                                                                          .toDate()),
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Medium',
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                    }),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  final pts = TextEditingController();
  reloadPointsDialog(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          )),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/Juan4All 2.png',
                      ),
                    ),
                    Form(
                      onChanged: () {
                        setState(() {});
                      },
                      child: TextFieldWidget(
                        inputType: TextInputType.number,
                        fontStyle: FontStyle.normal,
                        hint: 'Points to Reload',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        prefixIcon: Icons.control_point_duplicate,
                        isRequred: false,
                        controller: pts,
                        label: 'Points to Reload',
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ButtonWidget(
                      color: blue,
                      label: 'Confirm',
                      onPressed: pts.text == ''
                          ? () {}
                          : () async {
                              DocumentSnapshot doc = await FirebaseFirestore
                                  .instance
                                  .collection('Business')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get();

                              if (doc['wallet'] >= int.parse(pts.text)) {
                                // Prepare payment parameters
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                final email =
                                    FirebaseAuth.instance.currentUser!.email ??
                                        'noemail@example.com';
                                final int ptsToReload = int.parse(pts.text);
                                final String amountStr = (ptsToReload
                                        .toDouble())
                                    .toStringAsFixed(2); // PHP equals points
                                final String txnId =
                                    'TXN${DateTime.now().millisecondsSinceEpoch}';
                                final String description =
                                    'Points Reload $ptsToReload pts';

                                // Create a Payments doc with Pending status
                                await FirebaseFirestore.instance
                                    .collection('Payments')
                                    .doc(txnId)
                                    .set({
                                  'txnId': txnId,
                                  'userId': uid,
                                  'email': email,
                                  'amount': amountStr,
                                  'currency': 'PHP',
                                  'description': description,
                                  'type': 'points_reload',
                                  'pts': ptsToReload,
                                  'status': 'Pending',
                                  'createdAt': Timestamp.now(),
                                });

                                // Launch payment
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DragonPayWebView(
                                      txnId: txnId,
                                      amount: amountStr,
                                      description: description,
                                      email: email,
                                    ),
                                  ),
                                );

                                // Update Payments doc based on result
                                final bool success = (result == true);
                                await FirebaseFirestore.instance
                                    .collection('Payments')
                                    .doc(txnId)
                                    .update({
                                  'status': success ? 'Successful' : 'Failed',
                                  'updatedAt': Timestamp.now(),
                                });

                                if (success) {
                                  await FirebaseFirestore.instance
                                      .collection('Business')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    'wallet':
                                        FieldValue.increment(-ptsToReload),
                                    'pts': FieldValue.increment(ptsToReload),
                                  });

                                  showToast('Transaction was succesfull!');

                                  addPoints(ptsToReload, 1, name,
                                      'Points from reload', '');

                                  DocumentSnapshot doc1 =
                                      await FirebaseFirestore.instance
                                          .collection('Business')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .get();

                                  Navigator.pop(context);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => QRScannedPage(
                                            inuser: false,
                                            pts: doc1['pts'].toString(),
                                            store: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          )));
                                } else {
                                  showToast('Payment failed or canceled.');
                                  Navigator.pop(context);
                                }
                              } else {
                                showToast(
                                    'Cannot proceed! Insufficient e wallet');
                              }

                              pts.clear();
                            },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
