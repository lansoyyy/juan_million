import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CustomerPointsPage extends StatefulWidget {
  const CustomerPointsPage({super.key});

  @override
  State<CustomerPointsPage> createState() => _CustomerPointsPageState();
}

class _CustomerPointsPageState extends State<CustomerPointsPage> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWidget(
                      text: 'Screen Description:',
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextWidget(
                      text: '''
"Welcome to your Points screen! Here, you can view your point earnings from purchases. Every 150 points can be converted into 1 bonus slot. You can also transfer or share points with other members by simply scanning their QR codes. To claim a slot, just click the refresh button in the upper-right corner." 
''',
                      fontSize: 14,
                      maxLines: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final pts = TextEditingController();

  String selected = '';
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: blue,
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
                        text: 'Total Points',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWidget(
                          text: '${data['pts']}',
                          fontFamily: 'Bold',
                          fontSize: 75,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
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
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 100,
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
                                                showAmountDialog();
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
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
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
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => StorePage(
                                          inbusiness: false,
                                        )));
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
                                    text: 'Top up',
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
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextWidget(
                        text: 'Transactions',
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.docs.length,
                              itemBuilder: (context, index) {
                                double points =
                                    data.docs[index]['pts'].toDouble();
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
                                              '${incrementIfEndsWith49Or99(points)} points',
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'Medium',
                                        ),
                                        TextWidget(
                                          text: '${data.docs[index]['type']}',
                                          fontSize: 12,
                                          color: Colors.black,
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
            );
          }),
    );
  }

  showAmountDialog() {
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
                    showConfirmDialog(pts.text);
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

  showConfirmDialog(amount) {
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
                  Text(
                    'Service Charge (5%)- P ${(int.parse(amount) * 0.05).toStringAsFixed(0)}',
                    style: const TextStyle(
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
                    scanQRCode();
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

      if (qrCode != '-1') {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          DocumentSnapshot doc1 = await FirebaseFirestore.instance
              .collection('Users')
              .doc(qrCode)
              .get();

          if (doc1.exists) {
            if (documentSnapshot['pts'] >= int.parse(pts.text)) {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'pts': FieldValue.increment(-int.parse(pts.text)),
              });
              await FirebaseFirestore.instance
                  .collection(selected)
                  .doc(qrCode)
                  .update({
                'pts': FieldValue.increment(int.parse(pts.text)),
              }).whenComplete(
                () {
                  addWallet(
                      int.parse(pts.text),
                      qrCode,
                      FirebaseAuth.instance.currentUser!.uid,
                      'Receive & Transfers',
                      '');
                  Navigator.of(context).pop();

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => QRScannedPage(
                            fromWallet: true,
                            inuser: true,
                            pts: pts.text,
                            store: FirebaseAuth.instance.currentUser!.uid,
                          )));
                },
              );
            } else {
              Navigator.pop(context);
              showToast('Your points is not enough to proceed!');
            }
          } else {
            if (documentSnapshot['pts'] >= int.parse(pts.text)) {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'wallet': FieldValue.increment(-int.parse(pts.text)),
              });
              await FirebaseFirestore.instance
                  .collection(selected)
                  .doc(qrCode)
                  .update({
                'wallet': FieldValue.increment(int.parse(pts.text)),
              }).whenComplete(
                () {
                  addWallet(
                      int.parse(pts.text),
                      qrCode,
                      FirebaseAuth.instance.currentUser!.uid,
                      'Receive & Transfers',
                      '');
                  Navigator.of(context).pop();

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => QRScannedPage(
                            fromWallet: true,
                            inuser: true,
                            pts: pts.text,
                            store: FirebaseAuth.instance.currentUser!.uid,
                          )));
                },
              );
            } else {
              Navigator.pop(context);
              showToast('Your E wallet is not enough to proceed!');
            }
          }
        });
      } else {
        Navigator.pop(context);
      }
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  String incrementIfEndsWith49Or99(double number) {
    int wholeNumberPart = number.round();
    if (wholeNumberPart % 100 == 99 || wholeNumberPart % 100 == 49) {
      return (number + 1).toStringAsFixed(0);
    }
    return number.toStringAsFixed(0);
  }
}
