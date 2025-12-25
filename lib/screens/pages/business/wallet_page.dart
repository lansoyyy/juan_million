import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanner_screen.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:juan_million/widgets/transaction_receipt_dialog.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
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
“This is your E-Wallet dashboard. Here, you can receive payments from customers and track all your wallet transactions in one place.”
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

  final pin = TextEditingController();

  String selected = '';

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    // Check if desktop
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.white : primary,
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSidebar(context),
                Expanded(
                  child: _buildContent(context, userData),
                ),
              ],
            )
          : _buildContent(context, userData),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [blue, Colors.blue.shade900],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Juan Million',
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Business Dashboard',
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildSidebarItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildSidebarItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'E-Wallet',
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                TextWidget(
                  text: label,
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: isActive ? 'Bold' : 'Medium',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Stream<DocumentSnapshot> userData) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return StreamBuilder<DocumentSnapshot>(
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
                  if (!isDesktop)
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
                  const SizedBox(height: 30),
                  // Modern Wallet Balance Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.green.shade50],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextWidget(
                            text: 'E-Wallet Balance',
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Medium',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextWidget(
                                text: '₱',
                                fontSize: 32,
                                color: primary,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(width: 5),
                              TextWidget(
                                text: data['wallet'].toString(),
                                fontFamily: 'Bold',
                                fontSize: 56,
                                color: primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                TextWidget(
                                  text: 'Active',
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontFamily: 'Bold',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Modern Action Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Transfer Card
                          Expanded(
                            child: GestureDetector(
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

                                                                  final cashierUid = doc
                                                                              .data()
                                                                          is Map
                                                                      ? (doc.data()
                                                                              as Map)[
                                                                          'uid']
                                                                      : null;
                                                                  if (doc.exists &&
                                                                      cashierUid ==
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid) {
                                                                    showAmountDialog(
                                                                        doc['name'],
                                                                        false);
                                                                  } else {
                                                                    showToast(
                                                                        'Wrong PIN Code',
                                                                        context:
                                                                            context);
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

                                                                  final cashierUid = doc
                                                                              .data()
                                                                          is Map
                                                                      ? (doc.data()
                                                                              as Map)[
                                                                          'uid']
                                                                      : null;
                                                                  if (doc.exists &&
                                                                      cashierUid ==
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid) {
                                                                    showAmountDialog(
                                                                        doc['name'],
                                                                        false);
                                                                  } else {
                                                                    showToast(
                                                                        'Wrong PIN Code',
                                                                        context:
                                                                            context);
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
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  showToast(
                                      'Please register your authorized user account',
                                      context: context);
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sync_alt,
                                    color: primary,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text: 'Transfer',
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: VerticalDivider(
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
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

                                                  final cashierUid =
                                                      doc.data() is Map
                                                          ? (doc.data()
                                                              as Map)['uid']
                                                          : null;
                                                  if (doc.exists &&
                                                      cashierUid ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid) {
                                                    reloadPointsDialog(
                                                        doc['name']);
                                                  } else {
                                                    showToast('Wrong PIN Code',
                                                        context: context);
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
                                      'Please register your authorized user account',
                                      context: context);
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wallet,
                                    color: primary,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text: 'Reload points',
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Transactions',
                          fontSize: 18,
                          color: isDesktop ? Colors.black : Colors.white,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Wallets')
                                .where('from',
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
                                    final doc = data.docs[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: ListTile(
                                        onTap: () {
                                          TransactionReceiptDialog
                                              .showWalletReceipt(context, doc);
                                        },
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
                                                  .format(
                                                      doc['dateTime'].toDate()),
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontFamily: 'Medium',
                                            ),
                                            TextWidget(
                                              text: '${doc['pts']}',
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontFamily: 'Medium',
                                            ),
                                            TextWidget(
                                              text: '${doc['type']}',
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontFamily: 'Medium',
                                            ),
                                            TextWidget(
                                              text: 'By: ${doc['cashier']}',
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
        });
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
                                showToast('Transaction was succesfull!',
                                    context: context);

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
                                    'Cannot proceed! Insufficient e wallet',
                                    context: context);
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

  showAmountDialog(cashier, bool toCoor) {
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
                    if (toCoor) {
                      showConfirmDialog(pts.text, cashier);
                    } else {
                      Navigator.of(context).pop();
                      scanQRCode(cashier);
                    }
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
                  Text(
                    'Service Charge (3%)- P ${(int.parse(amount) * 0.03).toStringAsFixed(0)}',
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
                    Navigator.of(context).pop();
                    scanQRCode(cashier);
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

      final int amountValue = int.tryParse(pts.text) ?? 0;
      final int serviceCharge = (amountValue * 0.03).round();
      final int totalDebit = amountValue + serviceCharge;

      if (amountValue <= 0) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Please enter a valid amount', context: context);
        return;
      }

      final recipientDoc = await FirebaseFirestore.instance
          .collection(selected)
          .doc(result)
          .get();

      if (!recipientDoc.exists) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Invalid recipient QR code', context: context);
        return;
      }

      final businessDocRef = FirebaseFirestore.instance
          .collection('Business')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final businessSnap = await businessDocRef.get();
      final businessMap = businessSnap.data();
      final int currentWallet =
          (businessMap != null && businessMap['wallet'] is num)
              ? (businessMap['wallet'] as num).toInt()
              : 0;

      if (currentWallet < totalDebit) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Your wallet balance is not enough!', context: context);
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      batch.update(businessDocRef, {
        'wallet': FieldValue.increment(-totalDebit),
      });
      batch.update(
        FirebaseFirestore.instance.collection(selected).doc(result),
        {
          'wallet': FieldValue.increment(amountValue),
        },
      );

      await batch.commit();

      await addWallet(
        amountValue,
        FirebaseAuth.instance.currentUser!.uid,
        result,
        'Receive & Transfers',
        cashier,
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      showToast('Transaction was successful!', context: context);
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showToast('Failed to scan QR code', context: context);
    } catch (_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showToast('Transfer failed. Please try again.', context: context);
    }
  }
}
