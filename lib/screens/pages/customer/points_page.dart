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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic data = snapshot.data;
            return Column(
              children: [
                // Modern Gradient Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 30 : 20),
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextWidget(
                                text: 'My Points',
                                fontSize: isDesktop ? 28 : 24,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              const Spacer(),
                              const SizedBox(
                                  width: 48), // Balance for back button
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Points Display
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                TextWidget(
                                  text: 'Total Points',
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Medium',
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: '${data['pts']}',
                                      fontFamily: 'Bold',
                                      fontSize: isDesktop ? 80 : 70,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: TextWidget(
                                        text: 'pts',
                                        fontSize: 24,
                                        color: Colors.white.withOpacity(0.8),
                                        fontFamily: 'Bold',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.sync_alt_rounded,
                                  label: 'Transfer',
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Container(
                                          padding: const EdgeInsets.all(25),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              const SizedBox(height: 25),
                                              TextWidget(
                                                text: 'Transfer Points',
                                                fontSize: 20,
                                                fontFamily: 'Bold',
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 'Users';
                                                  });
                                                  Navigator.pop(context);
                                                  showAmountDialog();
                                                },
                                                leading: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        primary,
                                                        secondary
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.person_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                title: TextWidget(
                                                  text: 'To Member',
                                                  fontSize: 16,
                                                  fontFamily: 'Bold',
                                                ),
                                                subtitle: TextWidget(
                                                  text:
                                                      'Transfer points to another member',
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                                trailing: const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.wallet_rounded,
                                  label: 'Top Up',
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StorePage(inbusiness: false)));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Transactions Section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 30 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [primary, secondary]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.history_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            TextWidget(
                              text: 'Transactions',
                              fontSize: 22,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Points')
                                  .where('uid',
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

                                if (data.docs.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            size: 64,
                                            color: Colors.grey.shade300),
                                        const SizedBox(height: 15),
                                        TextWidget(
                                          text: 'No Transactions Yet',
                                          fontSize: 18,
                                          fontFamily: 'Medium',
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Desktop: 2-column grid, Mobile: list
                                return isDesktop
                                    ? GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          childAspectRatio: 3,
                                        ),
                                        itemCount: data.docs.length,
                                        itemBuilder: (context, index) {
                                          double points = data.docs[index]
                                                  ['pts']
                                              .toDouble();
                                          return _buildTransactionCard(
                                              data.docs[index], points, true);
                                        },
                                      )
                                    : ListView.builder(
                                        itemCount: data.docs.length,
                                        itemBuilder: (context, index) {
                                          double points = data.docs[index]
                                                  ['pts']
                                              .toDouble();
                                          return _buildTransactionCard(
                                              data.docs[index], points, false);
                                        },
                                      );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            TextWidget(
              text: label,
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Medium',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      dynamic transaction, double points, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.2),
                secondary.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.stars_rounded,
            color: primary,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: '${incrementIfEndsWith49Or99(points)} points',
              fontSize: 17,
              color: Colors.black87,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 4),
            TextWidget(
              text: '${transaction['type']}',
              fontSize: 13,
              color: Colors.grey.shade600,
              fontFamily: 'Medium',
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              TextWidget(
                text: DateFormat.yMMMd()
                    .add_jm()
                    .format(transaction['dateTime'].toDate()),
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Regular',
              ),
            ],
          ),
        ),
      ),
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
              showToast('Your points is not enough to proceed!',
                  context: context);
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
              showToast('Your E wallet is not enough to proceed!',
                  context: context);
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
