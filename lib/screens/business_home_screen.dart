import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/qr_page.dart';
import 'package:juan_million/screens/pages/business/cashier_screen.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/payment_selection_screen.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFieldWidget(
                                                showEye: true,
                                                isObscure: true,
                                                fontStyle: FontStyle.normal,
                                                hint: 'PIN Code',
                                                borderColor: blue,
                                                radius: 12,
                                                width: 350,
                                                prefixIcon: Icons.lock,
                                                isRequred: false,
                                                controller: pin,
                                                label: 'PIN Code',
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              ButtonWidget(
                                                label: 'Confirm',
                                                onPressed: () async {
                                                  DocumentSnapshot doc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Cashiers')
                                                          .doc(pin.text)
                                                          .get()
                                                          .whenComplete(() {
                                                    Navigator.pop(context);
                                                  });

                                                  if (doc.exists) {
                                                    if (mydata['pts'] > 1) {
                                                      int qty = 1;

                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            content: StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  TextWidget(
                                                                    text:
                                                                        'Input Amount Purchased',
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Regular',
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  TextFieldWidget(
                                                                    controller:
                                                                        amount,
                                                                    label:
                                                                        'Amount',
                                                                    inputType:
                                                                        TextInputType
                                                                            .number,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      MaterialButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(true),
                                                                        child:
                                                                            const Text(
                                                                          'Close',
                                                                          style: TextStyle(
                                                                              color: Colors.grey,
                                                                              fontFamily: 'Medium',
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      MaterialButton(
                                                                        onPressed:
                                                                            () async {
                                                                          addPoints(((int.parse(amount.text) * mydata['ptsconversion']) * 0.01).toInt(), qty, doc['name'])
                                                                              .then((value) {
                                                                            Navigator.of(context).pop(true);
                                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                                builder: (context) => QRPage(
                                                                                      id: value,
                                                                                    )));
                                                                          });
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Continue',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Bold',
                                                                              fontWeight: FontWeight.bold),
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
                                                      showToast(
                                                          "You don't have enough points.");
                                                    }
                                                  } else {
                                                    showToast(
                                                        'PIN Code does not exist!');
                                                  }
                                                },
                                              )
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
                                  Navigator.of(context).push(MaterialPageRoute(
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
                                text: 'Reload',
                                fontSize: 18,
                                fontFamily: 'Bold',
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            child: Card(
                              elevation: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                width: double.infinity,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/Juan4All 2.png',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            align: TextAlign.start,
                                            maxLines: 2,
                                            text: 'Reload your\nPOINTS!',
                                            fontSize: 18,
                                            color: blue,
                                            fontFamily: 'Bold',
                                          ),
                                          TextWidget(
                                            text: 'P1.00 per 1 Point',
                                            fontSize: 12,
                                            color: grey,
                                            fontFamily: 'Medium',
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          ButtonWidget(
                                            radius: 100,
                                            height: 30,
                                            width: 75,
                                            fontSize: 12,
                                            label: 'Reload',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
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
                                                            height: 20,
                                                          ),
                                                          ButtonWidget(
                                                            label: 'Confirm',
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);

                                                              DocumentSnapshot
                                                                  doc =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Cashiers')
                                                                      .doc(pin
                                                                          .text)
                                                                      .get();

                                                              if (doc.exists) {
                                                                reloadPointsDialog(
                                                                    doc['name']);
                                                              } else {
                                                                showToast(
                                                                    'PIN Code does not exist!');
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
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
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Points')
                                .where('uid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .where('scanned', isEqualTo: true)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                                        .collection('Users')
                                                        .doc(data.docs[index]
                                                            ['scannedId'])
                                                        .snapshots(),
                                                    builder: (context,
                                                        AsyncSnapshot<
                                                                DocumentSnapshot>
                                                            snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const Center(
                                                            child: Text(
                                                                'Loading'));
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
                                                            const EdgeInsets
                                                                .only(
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
                                                                      height:
                                                                          15,
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
                                                                      height:
                                                                          15,
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
                                                                          color:
                                                                              Colors.grey,
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
                      ],
                    ),
                  ],
                );
              }),
        ],
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
                                await FirebaseFirestore.instance
                                    .collection('Business')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'wallet': FieldValue.increment(
                                      -int.parse(pts.text)),
                                  'pts':
                                      FieldValue.increment(int.parse(pts.text))
                                });
                                showToast('Transaction was succesfull!');
                              } else {
                                showToast(
                                    'Cannot proceed! Insufficient cash wallet');
                              }

                              addPoints(int.parse(pts.text), 1, name);

                              DocumentSnapshot doc1 = await FirebaseFirestore
                                  .instance
                                  .collection('Business')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get();

                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => QRScannedPage(
                                        inuser: false,
                                        pts: doc1['pts'].toString(),
                                        store: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      )));

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
