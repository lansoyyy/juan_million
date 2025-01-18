import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final pin = TextEditingController();

  String selected = '';

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      backgroundColor: primary,
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
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextWidget(
                        text: 'Wallet',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: TextWidget(
                        text: data['wallet'].toString(),
                        fontFamily: 'Bold',
                        fontSize: 75,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        width: double.infinity,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('Cashiers')
                                    .where('uid',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .get();

                                if (snapshot.docs.isNotEmpty) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return SizedBox(
                                        height: 230,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 'Users';
                                                  });
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFieldWidget(
                                                                showEye: true,
                                                                isObscure: true,
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
                                                                    Icons.lock,
                                                                isRequred:
                                                                    false,
                                                                controller: pin,
                                                                label:
                                                                    'PIN Code',
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
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
                                                                    showAmountDialog(
                                                                        doc['name']);
                                                                  } else {
                                                                    showToast(
                                                                        'PIN Code does not exist!');
                                                                  }

                                                                  pin.clear();
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                leading: const Icon(
                                                  Icons.person,
                                                ),
                                                title: TextWidget(
                                                  text: 'To member',
                                                  fontSize: 14,
                                                  fontFamily: 'Bold',
                                                ),
                                              ),
                                              const Divider(),
                                              ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 'Business';
                                                  });
                                                  Navigator.pop(context);

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFieldWidget(
                                                                showEye: true,
                                                                isObscure: true,
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
                                                                    Icons.lock,
                                                                isRequred:
                                                                    false,
                                                                controller: pin,
                                                                label:
                                                                    'PIN Code',
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
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
                                                                    showAmountDialog(
                                                                        doc['name']);
                                                                  } else {
                                                                    showToast(
                                                                        'PIN Code does not exist!');
                                                                  }

                                                                  pin.clear();
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                leading: const Icon(
                                                  Icons.business,
                                                ),
                                                title: TextWidget(
                                                  text: 'To affiliate',
                                                  fontSize: 14,
                                                  fontFamily: 'Bold',
                                                ),
                                              ),
                                              const Divider(),
                                              ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 'Coordinator';
                                                  });
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFieldWidget(
                                                                showEye: true,
                                                                isObscure: true,
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
                                                                    Icons.lock,
                                                                isRequred:
                                                                    false,
                                                                controller: pin,
                                                                label:
                                                                    'PIN Code',
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
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
                                                                    showAmountDialog(
                                                                        doc['name']);
                                                                  } else {
                                                                    showToast(
                                                                        'PIN Code does not exist!');
                                                                  }

                                                                  pin.clear();
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                leading: const Icon(
                                                  Icons.person_4_rounded,
                                                ),
                                                title: TextWidget(
                                                  text: 'To coordinator',
                                                  fontSize: 14,
                                                  fontFamily: 'Bold',
                                                ),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sync_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  TextWidget(
                                    text: 'Transfer',
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: VerticalDivider(
                                color: Colors.white,
                                thickness: 0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) => StorePage(
                                //           inbusiness: true,
                                //         )));

                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('Cashiers')
                                    .where('uid',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .get();

                                if (snapshot.docs.isNotEmpty) {
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
                                                  Navigator.pop(context);

                                                  DocumentSnapshot doc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Cashiers')
                                                          .doc(pin.text)
                                                          .get();

                                                  if (doc.exists) {
                                                    reloadPointsDialog(
                                                        doc['name']);
                                                  } else {
                                                    showToast(
                                                        'PIN Code does not exist!');
                                                  }

                                                  pin.clear();
                                                },
                                              )
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.wallet,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  TextWidget(
                                    text: 'Reload points',
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          TextWidget(
                            text: 'Transactions',
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Wallets')
                                  .where('from',
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser!.uid)
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
                                  height: 1000,
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: data.docs.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          tileColor: Colors.white,
                                          leading: Icon(
                                            Icons.volunteer_activism_outlined,
                                            color: secondary,
                                            size: 32,
                                          ),
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(data.docs[index]
                                                            ['dateTime']
                                                        .toDate()),
                                                fontSize: 11,
                                                color: Colors.grey,
                                                fontFamily: 'Medium',
                                              ),
                                              TextWidget(
                                                text:
                                                    '${data.docs[index]['pts']}',
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: 'Medium',
                                              ),
                                              TextWidget(
                                                text:
                                                    '${data.docs[index]['type']}',
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontFamily: 'Medium',
                                              ),
                                              TextWidget(
                                                text:
                                                    'By: ${data.docs[index]['cashier']}',
                                                fontSize: 11,
                                                color: Colors.grey,
                                                fontFamily: 'Medium',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
                        setState(
                          () {},
                        );
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

                                addPoints(int.parse(pts.text), 1, name,
                                    'Points from reload', '');

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

  showAmountDialog(cashier) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                'Enter amount',
                style: TextStyle(
                    fontFamily: 'Bold',
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    prefixIcon: null,
                    inputType: TextInputType.number,
                    controller: pts,
                    label: 'Amount',
                  ),
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    showConfirmDialog(pts.text, cashier);
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  showConfirmDialog(amount, cashier) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      maxRadius: 35,
                      minRadius: 35,
                      backgroundImage:
                          AssetImage('assets/images/Juan4All 2.png'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Amount - $amount',
                    style: const TextStyle(
                        fontFamily: 'Bold',
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Text(
                    'Sevice Charge (5%)- P 50',
                    style: TextStyle(
                        fontFamily: 'Bold',
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.normal),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    scanQRCode(cashier);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ));
  }

  String qrCode = 'Unknown';

  Future<void> scanQRCode(String cashier) async {
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

      if (qrCode != '-1') {
        await FirebaseFirestore.instance
            .collection('Business')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          if (documentSnapshot['wallet'] > int.parse(pts.text)) {
            await FirebaseFirestore.instance
                .collection(selected)
                .doc(qrCode)
                .update({
              'wallet': FieldValue.increment(int.parse(pts.text)),
            });
            await FirebaseFirestore.instance
                .collection('Business')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'wallet': FieldValue.increment(-int.parse(pts.text)),
            });
          } else {
            showToast('Your wallet balance is not enough!');
          }
        }).whenComplete(() {
          // Add transaction

          addWallet(int.parse(pts.text), FirebaseAuth.instance.currentUser!.uid,
              qrCode, 'Receive & Transfers', cashier);
          Navigator.of(context).pop();
        });
      } else {
        Navigator.pop(context);
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }
}
