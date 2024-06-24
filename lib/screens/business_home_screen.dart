import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/qr_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/payment_selection_screen.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      body: Column(
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
                    Container(
                      width: double.infinity,
                      color: blue,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: SafeArea(
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
                                  if (mydata['pts'] > 1) {
                                    int qty = 1;

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: StatefulBuilder(
                                              builder: (context, setState) {
                                            int total =
                                                mydata['ptsconversion'] * qty;
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextWidget(
                                                  text: 'Input quantity',
                                                  fontSize: 12,
                                                  fontFamily: 'Regular',
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        if (qty > 1) {
                                                          setState(() {
                                                            qty--;
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.remove,
                                                        size: 50,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    TextWidget(
                                                      text: qty.toString(),
                                                      fontSize: 48,
                                                      fontFamily: 'Bold',
                                                      color: blue,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        if (mydata['pts'] >
                                                            total) {
                                                          setState(() {
                                                            qty++;
                                                          });
                                                        } else {
                                                          showToast(
                                                              'Points not enough!');
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    MaterialButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: const Text(
                                                        'Close',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontFamily:
                                                                'Medium',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    MaterialButton(
                                                      onPressed: () async {
                                                        addPoints(total, qty)
                                                            .then((value) {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          QRPage(
                                                                            id: value,
                                                                          )));
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Continue',
                                                        style: TextStyle(
                                                            fontFamily: 'Bold',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        );
                                      },
                                    );
                                  } else {
                                    showToast("You don't have enough points.");
                                  }
                                },
                                icon: const Icon(
                                  Icons.qr_code,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
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
                                    builder: (context) => const PointsPage()));
                              } else if (index == 1) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const WalletPage()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const InventoryPage()));
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
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextWidget(
                                          text: index == 0
                                              ? 'Total Points'
                                              : index == 1
                                                  ? 'Cash Wallet'
                                                  : 'Customers',
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50, right: 50),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                      .collection('Points')
                                                      .where('uid',
                                                          isEqualTo: mydata.id)
                                                      .where('scanned',
                                                          isEqualTo: true)
                                                      .snapshots(),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                    if (snapshot.hasError) {
                                                      print(snapshot.error);
                                                      return const Center(
                                                          child: Text('Error'));
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

                                                    final data =
                                                        snapshot.requireData;
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextWidget(
                                                          text: index == 0
                                                              ? '${mydata['pts']}'
                                                              : index == 1
                                                                  ? AppConstants
                                                                      .formatNumberWithPeso(
                                                                          mydata[
                                                                              'wallet'])
                                                                  : data.docs
                                                                      .length
                                                                      .toString(),
                                                          fontFamily: 'Bold',
                                                          fontSize: 50,
                                                          color: Colors.white,
                                                        ),
                                                      ],
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
                                                text: '0 Slots',
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
                                text: 'Store',
                                fontSize: 18,
                                fontFamily: 'Bold',
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => StorePage(
                                            inbusiness: true,
                                          )));
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
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentSelectionScreen(
                                                          inbusiness: true,
                                                          item:
                                                              data.docs[index],
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
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text:
                                                          'P${data.docs[index]['price']}',
                                                      fontSize: 14,
                                                      fontFamily: 'Medium',
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
                                                          fontFamily: 'Bold',
                                                          color: blue,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: 'pts',
                                                          fontSize: 12,
                                                          fontFamily: 'Bold',
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
                                                          color: secondary,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: 'Limited offer',
                                                          fontSize: 10,
                                                          fontFamily: 'Bold',
                                                          color: Colors.black,
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => StorePage(
                                            inbusiness: true,
                                          )));
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
                                    itemCount: 2,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentSelectionScreen(
                                                          inbusiness: true,
                                                          item:
                                                              data.docs[index],
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
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text:
                                                          'P${data.docs[index]['price']}',
                                                      fontSize: 14,
                                                      fontFamily: 'Medium',
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
                                                          fontFamily: 'Bold',
                                                          color: blue,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: 'pts',
                                                          fontSize: 12,
                                                          fontFamily: 'Bold',
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
                                                          color: secondary,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: 'Limited offer',
                                                          fontSize: 10,
                                                          fontFamily: 'Bold',
                                                          color: Colors.black,
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
              }),
        ],
      ),
    );
  }
}
