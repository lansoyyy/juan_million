import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/customer/inventory_page.dart';
import 'package:juan_million/screens/pages/customer/notif_page.dart';
import 'package:juan_million/screens/pages/customer/points_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/customer/settings_page.dart';
import 'package:juan_million/screens/pages/customer/wallet_page.dart';
import 'package:juan_million/screens/pages/payment_selection_screen.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_slots.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String qrCode = 'Unknown';
  String store = '';
  String pts = '';

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
        setState(() {
          pts = documentSnapshot['pts'].toString();
          store = documentSnapshot['uid'];
        });
      }).whenComplete(() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QRScannedPage(
                  pts: pts,
                  store: store,
                )));
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  void checkPoints(int points, int limit) {
    if (points > limit) {
      int total = points - limit;

      int slots = total ~/ limit;
      print(slots);

      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(-total),
      });

      FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet')
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(total),
      });

      // Add to Slot

      for (int i = 0; i < slots; i++) {
        addSlots();
      }
    } else {
      print('Points are within the limit.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Slots')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('dateTime',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day)))
              .where('dateTime',
                  isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day + 1)
                      .subtract(const Duration(seconds: 1))))
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                )),
              );
            }

            final slotdata = snapshot.requireData;

            return StreamBuilder<DocumentSnapshot>(
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
                  dynamic data = snapshot.data;

                  if (slotdata.docs.length <= 10) {
                    checkPoints(data['pts'], 149);
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: blue,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                TextWidget(
                                  text: 'Hello ka-Juan!',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                IconButton(
                                  onPressed: () {
                                    scanQRCode();
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
                                                const CustomerNotifPage()));
                                  },
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CustomerSettingsPage()));
                                  },
                                  icon: const Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        width: 500,
                        child: ListView.builder(
                          itemCount: 3,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (index == 0) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerPointsPage()));
                                } else if (index == 1) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerWalletPage()));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerInventoryPage()));
                                }
                              },
                              child: Center(
                                child: Container(
                                  width: 425,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? blue
                                        : index == 1
                                            ? primary
                                            : secondary,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(1000),
                                      bottomRight: Radius.circular(1000),
                                    ),
                                  ),
                                  child: SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 5),
                                      child: Column(
                                        children: [
                                          TextWidget(
                                            text: index == 0
                                                ? 'Total Points'
                                                : index == 1
                                                    ? 'Cash Wallet'
                                                    : 'Community Wallet',
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 50, right: 50),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                index != 0
                                                    ? const Icon(
                                                        Icons
                                                            .keyboard_arrow_left_rounded,
                                                        color: Colors.white60,
                                                        size: 50,
                                                      )
                                                    : const SizedBox(
                                                        width: 50,
                                                      ),
                                                StreamBuilder<QuerySnapshot>(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('Slots')
                                                        .where('uid',
                                                            isEqualTo:
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                        .snapshots(),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<
                                                                QuerySnapshot>
                                                            snapshot) {
                                                      if (snapshot.hasError) {
                                                        print(snapshot.error);
                                                        return const Center(
                                                            child:
                                                                Text('Error'));
                                                      }
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 50),
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                            color: Colors.black,
                                                          )),
                                                        );
                                                      }

                                                      final mydata =
                                                          snapshot.requireData;

                                                      return TextWidget(
                                                        text: index == 0
                                                            ? '${data['pts']}'
                                                            : index == 1
                                                                ? AppConstants
                                                                    .formatNumberWithPeso(
                                                                        data[
                                                                            'wallet'])
                                                                : mydata
                                                                    .docs.length
                                                                    .toString(),
                                                        fontFamily: 'Bold',
                                                        fontSize: 50,
                                                        color: Colors.white,
                                                      );
                                                    }),
                                                index == 2
                                                    ? const SizedBox(
                                                        width: 50,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .keyboard_arrow_right_rounded,
                                                        color: Colors.white60,
                                                        size: 50,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          index == 2
                                              ? TextWidget(
                                                  text: 'Your Slot/s',
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Points')
                              .where('scannedId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return const Center(child: Text('Error'));
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
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  data.docs.isEmpty
                                      ? Center(
                                          child: TextWidget(
                                            text: 'No Recent Activity',
                                            fontSize: 14,
                                            fontFamily: 'Regular',
                                            color: Colors.grey,
                                          ),
                                        )
                                      : SizedBox(
                                          height: 150,
                                          width: 500,
                                          child: ListView.builder(
                                            itemCount: data.docs.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return StreamBuilder<
                                                      DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('Business')
                                                      .doc(data.docs[index]
                                                          ['uid'])
                                                      .snapshots(),
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot>
                                                          snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const Center(
                                                          child:
                                                              Text('Loading'));
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Center(
                                                          child: Text(
                                                              'Something went wrong'));
                                                    } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                    dynamic businessdata =
                                                        snapshot.data;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: GestureDetector(
                                                        child: Card(
                                                          elevation: 5,
                                                          color: Colors.white,
                                                          child: SizedBox(
                                                            height: 150,
                                                            width: 150,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Center(
                                                                    child:
                                                                        TextWidget(
                                                                      text: businessdata[
                                                                          'name'],
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Medium',
                                                                      color:
                                                                          blue,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
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
                                                                            5,
                                                                      ),
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
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      TextWidget(
                                                                        text: DateFormat.yMMMd()
                                                                            .add_jm()
                                                                            .format(data.docs[index]['dateTime'].toDate()),
                                                                        fontSize:
                                                                            10,
                                                                        fontFamily:
                                                                            'Bold',
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 10,
                      ),
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
                                  text: 'Promo & Deals',
                                  fontSize: 18,
                                  fontFamily: 'Bold',
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => StorePage()));
                                  },
                                  child: TextWidget(
                                    text: 'See all',
                                    color: blue,
                                    fontSize: 14,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Boosters')
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    print(snapshot.error);
                                    return const Center(child: Text('Error'));
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
                                  return SizedBox(
                                    height: 150,
                                    width: 500,
                                    child: ListView.builder(
                                      itemCount: data.docs.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return data.docs[index]['price'] ==
                                                    250 ||
                                                data.docs[index]['price'] == 20
                                            ? const SizedBox()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PaymentSelectionScreen(
                                                                  item: data
                                                                          .docs[
                                                                      index],
                                                                )));
                                                  },
                                                  child: Card(
                                                    elevation: 5,
                                                    color: Colors.white,
                                                    child: SizedBox(
                                                      height: 150,
                                                      width: 150,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'P${data.docs[index]['price']}',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                              color: blue,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                TextWidget(
                                                                  text:
                                                                      '${data.docs[index]['slots'] * 150}',
                                                                  fontSize: 38,
                                                                  fontFamily:
                                                                      'Bold',
                                                                  color: blue,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text: 'pts',
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Bold',
                                                                  color: blue,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.circle,
                                                                  color:
                                                                      secondary,
                                                                  size: 15,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text:
                                                                      'Limited offer',
                                                                  fontSize: 10,
                                                                  fontFamily:
                                                                      'Bold',
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ],
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
                                })
                          ],
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}
