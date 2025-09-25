import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/affiliates_locator_page.dart';
import 'package:juan_million/screens/pages/customer/inventory_page.dart';
import 'package:juan_million/screens/pages/customer/myqr_page.dart';
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

      print('qr value $qrCode');

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
      });

      if (qrCode != '-1') {
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

            await FirebaseFirestore.instance
                .collection('Community Wallet')
                .doc('wallet')
                .update({
              // 'wallet': FieldValue.increment(total),
              'pts': FieldValue.increment(documentSnapshot['pts']),
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
      } else {
        Navigator.pop(context);
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  void checkPoints(int limit) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot['pts'].toInt() >= limit) {
        await FirebaseFirestore.instance
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
            .get()
            .then((snapshot) {
          int total = documentSnapshot['pts'].toInt() - limit;

          int slotsFromPoints = documentSnapshot['pts'].toInt() ~/ limit;
          int currentSlots = snapshot.docs.length;
          int slotsLeft = 5 - currentSlots;

          if (slotsFromPoints > slotsLeft) {
            FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              // 'wallet': FieldValue.increment(total),
              'pts': FieldValue.increment(-slotsLeft * limit),
            });
            for (int i = 0; i < slotsLeft; i++) {
              addSlots();

              // FirebaseFirestore.instance
              //     .collection('Users')
              //     .doc(FirebaseAuth.instance.currentUser!.uid)
              //     .update({
              //   // 'wallet': FieldValue.increment(total),
              //   'pts': FieldValue.increment(-150),
              // });

              // FirebaseFirestore.instance
              //     .collection('Community Wallet')
              //     .doc('wallet')
              //     .update({
              //   // 'wallet': FieldValue.increment(total),
              //   'pts': FieldValue.increment(150),
              // });
            }
          } else {
            FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              // 'wallet': FieldValue.increment(total),
              'pts': FieldValue.increment(-slotsFromPoints * limit),
            });
            for (int i = 0; i < slotsFromPoints; i++) {
              addSlots();

              // FirebaseFirestore.instance
              //     .collection('Users')
              //     .doc(FirebaseAuth.instance.currentUser!.uid)
              //     .update({
              //   // 'wallet': FieldValue.increment(total),
              //   'pts': FieldValue.increment(-150),
              // });

              // FirebaseFirestore.instance
              //     .collection('Community Wallet')
              //     .doc('wallet')
              //     .update({
              //   // 'wallet': FieldValue.increment(total),
              //   'pts': FieldValue.increment(150),
              // });
            }
          }
        });

        // Add to Slot
      } else {
        print('Points are within the limit.');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    checkPoints(150);
    // TODO: implement initState
    super.initState();
  }

  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  // Helper method to build header icon buttons
  Widget _buildHeaderIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 5),
          TextWidget(
            text: label,
            fontSize: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: scanQRCode,
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: userData,
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('Loading'));
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              dynamic data = snapshot.data;

              // if (mypoints < 0) {
              //   FirebaseFirestore.instance
              //       .collection('Users')
              //       .doc(FirebaseAuth.instance.currentUser!.uid)
              //       .update({
              //     'pts': mypoints.abs(),
              //   });
              // }

              return Column(
                children: [
                  // Improved header with gradient and better styling
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          blue,
                          blue.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: 'Hello ka-Juan!',
                                        fontSize: 22,
                                        fontFamily: 'Bold',
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 5),
                                      TextWidget(
                                        text: 'Welcome back to Juan4All',
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => MyQRPage(
                                                      isPoints: true,
                                                    )));
                                      },
                                      icon: const Icon(
                                        Icons.qr_code,
                                        color: Colors.white,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const CustomerHomeScreen()),
                                          (route) => false,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.sync,
                                        color: Colors.white,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildHeaderIconButton(
                                  icon: Icons.business,
                                  label: 'Affiliates',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AffiliateLocatorPage()));
                                  },
                                ),
                                _buildHeaderIconButton(
                                  icon: Icons.notifications,
                                  label: 'Notifications',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CustomerNotifPage()));
                                  },
                                ),
                                _buildHeaderIconButton(
                                  icon: Icons.account_circle,
                                  label: 'Settings',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CustomerSettingsPage()));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Enhanced wallet cards section
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: PageView.builder(
                      itemCount: 3,
                      controller: PageController(viewportFraction: 0.85),
                      onPageChanged: (index) {
                        // Handle page change if needed
                      },
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(
                            right: index == 2 ? 0 : 15,
                            left: index == 0 ? 0 : 15,
                          ),
                          child: GestureDetector(
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
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: index == 0
                                      ? [blue, blue.withOpacity(0.7)]
                                      : index == 1
                                          ? [primary, primary.withOpacity(0.7)]
                                          : [
                                              secondary,
                                              secondary.withOpacity(0.7)
                                            ],
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
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: index == 0
                                              ? 'Total Points'
                                              : index == 1
                                                  ? 'E Wallet'
                                                  : 'Community Wallet',
                                          fontSize: 16,
                                          fontFamily: 'Medium',
                                          color: Colors.white,
                                        ),
                                        Icon(
                                          index == 0
                                              ? Icons.star
                                              : index == 1
                                                  ? Icons.account_balance_wallet
                                                  : Icons.group,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Expanded(
                                      child: Center(
                                        child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('Slots')
                                                .where('uid',
                                                    isEqualTo: FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid)
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

                                              final mydata =
                                                  snapshot.requireData;

                                              return TextWidget(
                                                text: index == 0
                                                    ? '${data['pts'].toInt()}'
                                                    : index == 1
                                                        ? AppConstants
                                                            .formatNumberWithPeso(
                                                                data['wallet'])
                                                        : mydata.docs.length
                                                            .toString(),
                                                fontFamily: 'Bold',
                                                fontSize: 36,
                                                color: Colors.white,
                                              );
                                            }),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    index == 2
                                        ? Center(
                                            child: TextWidget(
                                              text: 'Your Slot/s',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
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
                  // Enhanced recent activity section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              text: 'Recent Activity',
                              fontSize: 20,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Points')
                                .where('uid',
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
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ));
                              }

                              final data = snapshot.requireData;
                              return data.docs.isEmpty
                                  ? Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: TextWidget(
                                          text: 'No Recent Activity',
                                          fontSize: 16,
                                          fontFamily: 'Regular',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 180,
                                      child: ListView.builder(
                                        itemCount: data.docs.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return StreamBuilder<
                                                  DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('Business')
                                                  .doc(data.docs[index]['uid'])
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          DocumentSnapshot>
                                                      snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Center(
                                                      child: Text('Loading'));
                                                } else if (snapshot.hasError) {
                                                  return const Center(
                                                      child: Text(
                                                          'Something went wrong'));
                                                } else if (snapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }
                                                dynamic businessdata =
                                                    snapshot.data;
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  margin: const EdgeInsets.only(
                                                      right: 15),
                                                  child: GestureDetector(
                                                    child: Container(
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                            spreadRadius: 1,
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  child:
                                                                      TextWidget(
                                                                    text: businessdata[
                                                                        'name'],
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Medium',
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                                const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                  size: 16,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  TextWidget(
                                                                    text: (data
                                                                            .docs[index][
                                                                                'pts']
                                                                            .ceilToDouble())
                                                                        .toStringAsFixed(
                                                                            0),
                                                                    fontSize:
                                                                        32,
                                                                    fontFamily:
                                                                        'Bold',
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  TextWidget(
                                                                    text: 'pts',
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Bold',
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                            Center(
                                                              child: TextWidget(
                                                                text: DateFormat
                                                                        .yMMMd()
                                                                    .add_jm()
                                                                    .format(data
                                                                        .docs[
                                                                            index]
                                                                            [
                                                                            'dateTime']
                                                                        .toDate()),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Regular',
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                    );
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20, right: 20),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         crossAxisAlignment: CrossAxisAlignment.end,
                  //         children: [
                  //           TextWidget(
                  //             text: 'Promo & Deals',
                  //             fontSize: 18,
                  //             fontFamily: 'Bold',
                  //           ),
                  //           GestureDetector(
                  //             onTap: () {
                  //               Navigator.of(context).push(MaterialPageRoute(
                  //                   builder: (context) => StorePage()));
                  //             },
                  //             child: TextWidget(
                  //               text: 'See all',
                  //               color: blue,
                  //               fontSize: 14,
                  //               fontFamily: 'Bold',
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(
                  //         height: 5,
                  //       ),
                  //       StreamBuilder<QuerySnapshot>(
                  //           stream: FirebaseFirestore.instance
                  //               .collection('Boosters')
                  //               .snapshots(),
                  //           builder: (BuildContext context,
                  //               AsyncSnapshot<QuerySnapshot> snapshot) {
                  //             if (snapshot.hasError) {
                  //               print(snapshot.error);
                  //               return const Center(child: Text('Error'));
                  //             }
                  //             if (snapshot.connectionState ==
                  //                 ConnectionState.waiting) {
                  //               return const Padding(
                  //                 padding: EdgeInsets.only(top: 50),
                  //                 child: Center(
                  //                     child: CircularProgressIndicator(
                  //                   color: Colors.black,
                  //                 )),
                  //               );
                  //             }

                  //             final data = snapshot.requireData;
                  //             return SizedBox(
                  //               height: 150,
                  //               width: 500,
                  //               child: ListView.builder(
                  //                 itemCount: data.docs.length,
                  //                 scrollDirection: Axis.horizontal,
                  //                 itemBuilder: (context, index) {
                  //                   return data.docs[index]['price'] == 250 ||
                  //                           data.docs[index]['price'] == 20
                  //                       ? const SizedBox()
                  //                       : Padding(
                  //                           padding: const EdgeInsets.only(
                  //                               left: 5, right: 5),
                  //                           child: GestureDetector(
                  //                             onTap: () {
                  //                               Navigator.of(context).push(
                  //                                   MaterialPageRoute(
                  //                                       builder: (context) =>
                  //                                           PaymentSelectionScreen(
                  //                                             item: data
                  //                                                 .docs[index],
                  //                                           )));
                  //                             },
                  //                             child: Card(
                  //                               elevation: 5,
                  //                               color: Colors.white,
                  //                               child: SizedBox(
                  //                                 height: 150,
                  //                                 width: 150,
                  //                                 child: Padding(
                  //                                   padding:
                  //                                       const EdgeInsets.all(
                  //                                           10.0),
                  //                                   child: Column(
                  //                                     crossAxisAlignment:
                  //                                         CrossAxisAlignment
                  //                                             .start,
                  //                                     children: [
                  //                                       TextWidget(
                  //                                         text:
                  //                                             'P${data.docs[index]['price']}',
                  //                                         fontSize: 14,
                  //                                         fontFamily: 'Medium',
                  //                                         color: blue,
                  //                                       ),
                  //                                       const SizedBox(
                  //                                         height: 15,
                  //                                       ),
                  //                                       Row(
                  //                                         mainAxisAlignment:
                  //                                             MainAxisAlignment
                  //                                                 .center,
                  //                                         children: [
                  //                                           TextWidget(
                  //                                             text:
                  //                                                 '${data.docs[index]['slots'] * 150}',
                  //                                             fontSize: 38,
                  //                                             fontFamily:
                  //                                                 'Bold',
                  //                                             color: blue,
                  //                                           ),
                  //                                           const SizedBox(
                  //                                             width: 5,
                  //                                           ),
                  //                                           TextWidget(
                  //                                             text: 'pts',
                  //                                             fontSize: 12,
                  //                                             fontFamily:
                  //                                                 'Bold',
                  //                                             color: blue,
                  //                                           ),
                  //                                         ],
                  //                                       ),
                  //                                       const SizedBox(
                  //                                         height: 15,
                  //                                       ),
                  //                                       Row(
                  //                                         mainAxisAlignment:
                  //                                             MainAxisAlignment
                  //                                                 .center,
                  //                                         children: [
                  //                                           Icon(
                  //                                             Icons.circle,
                  //                                             color: secondary,
                  //                                             size: 15,
                  //                                           ),
                  //                                           const SizedBox(
                  //                                             width: 5,
                  //                                           ),
                  //                                           TextWidget(
                  //                                             text:
                  //                                                 'Limited offer',
                  //                                             fontSize: 10,
                  //                                             fontFamily:
                  //                                                 'Bold',
                  //                                             color:
                  //                                                 Colors.black,
                  //                                           ),
                  //                                         ],
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         );
                  //                 },
                  //               ),
                  //             );
                  //           })
                  //     ],
                  //   ),
                  // ),
                ],
              );
            }));
  }
}
