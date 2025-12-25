import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/business/cashier_screen.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/business/payments_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanner_screen.dart';
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

  late final String _currentBusinessId;
  late final Stream<DocumentSnapshot> _businessData;

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
      showToast('Unauthorized to access this feature!', context: context);
      print("Error: ${e.message}");
    }
  }

  String qrCode = 'Unknown';

  Future<void> scanQRCode(int transferredPts, String cashier) async {
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

      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(result);
      final businessRef = FirebaseFirestore.instance
          .collection('Business')
          .doc(_currentBusinessId);
      final communityRef = FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet');

      final userSnap = await userRef.get();
      if (!userSnap.exists) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Invalid recipient QR code', context: context);
        return;
      }

      final businessSnap = await businessRef.get();
      final businessData = businessSnap.data();
      final businessMap = (businessData is Map) ? businessData : null;
      final ptsField = businessMap != null ? businessMap['pts'] : null;
      final int currentPts = (ptsField is num) ? ptsField.toInt() : 0;

      if (currentPts < transferredPts) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Your points balance is not enough', context: context);
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      batch.update(userRef, {
        'pts': FieldValue.increment(transferredPts),
      });
      batch.update(businessRef, {
        'pts': FieldValue.increment(-transferredPts),
      });
      batch.update(communityRef, {
        'pts': FieldValue.increment(transferredPts),
      });
      await batch.commit();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await addPoints(
        transferredPts,
        1,
        cashier,
        'Points received by member',
        userSnap.id,
      );

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QRScannedPage(
                fromScan: true,
                inuser: false,
                fromWallet: true,
                pts: transferredPts.toString(),
                store: result,
              )));
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

  @override
  void initState() {
    _currentBusinessId = FirebaseAuth.instance.currentUser!.uid;
    _businessData = FirebaseFirestore.instance
        .collection('Business')
        .doc(_currentBusinessId)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final Stream<DocumentSnapshot> userData = _businessData;

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
            dynamic mydata = snapshot.data;

            return isDesktop
                ? _buildDesktopLayout(mydata, isDesktop)
                : _buildMobileLayout(mydata);
          }),
    );
  }

  // Mobile Layout - Modern UI like Customer Home
  Widget _buildMobileLayout(dynamic mydata) {
    return SingleChildScrollView(
        child: Column(children: [
      // Modern Curved Header
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blue, Colors.blue.shade900],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: blue.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Hello ka-Juan! 👋',
                            fontSize: 28,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: mydata['name'] ?? 'Business User',
                            fontSize: 14,
                            fontFamily: 'Regular',
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildHeaderAction(
                          Icons.qr_code_scanner_rounded,
                          () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget(
                                              text: 'Scan QR',
                                              fontSize: 18,
                                              fontFamily: 'Bold',
                                              color: Colors.black87,
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
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
                                        const SizedBox(height: 20),
                                        ButtonWidget(
                                          label: 'Confirm',
                                          onPressed: () async {
                                            DocumentSnapshot doc =
                                                await FirebaseFirestore.instance
                                                    .collection('Cashiers')
                                                    .doc(pin.text)
                                                    .get()
                                                    .whenComplete(() {
                                              Navigator.pop(context);
                                            });

                                            final cashierUid = doc.data() is Map
                                                ? (doc.data() as Map)['uid']
                                                : null;

                                            if (doc.exists &&
                                                cashierUid ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid) {
                                              if (mydata['pts'] > 1) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      title: TextWidget(
                                                        text:
                                                            'Input Amount Purchased',
                                                        fontSize: 18,
                                                        fontFamily: 'Regular',
                                                        color: Colors.grey,
                                                      ),
                                                      content: StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20,
                                                                  bottom: 20),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFieldWidget(
                                                                controller:
                                                                    amount,
                                                                label: 'Amount',
                                                                inputType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child:
                                                                        TextWidget(
                                                                      text:
                                                                          'Close',
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          'Medium',
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      scanQRCode(
                                                                        ((double.parse(amount.text) * mydata['ptsconversion']) *
                                                                                0.01)
                                                                            .toInt(),
                                                                        doc['name'],
                                                                      );
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          blue,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        TextWidget(
                                                                      text:
                                                                          'Continue',
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          'Bold',
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
                                                    "You don't have enough points.",
                                                    context: context);
                                              }
                                            } else {
                                              showToast('Wrong PIN Code',
                                                  context: context);
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
                        ),
                        const SizedBox(width: 12),
                        _buildHeaderAction(
                          Icons.settings_rounded,
                          () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SettingsPage()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      Icons.groups_2_outlined,
                      'Cashiers',
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CashiersScreen()));
                      },
                    ),
                    _buildQuickAction(
                      Icons.payment_rounded,
                      'Payments',
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PaymentsPage()));
                      },
                    ),
                    _buildQuickAction(
                      Icons.history_rounded,
                      'Inventory',
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const InventoryPage()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // Wallet Cards
      Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildMobileWalletCard(
              'Points Inventory',
              '${mydata['pts']}',
              Icons.stars_rounded,
              [blue, Colors.blue.shade800],
              () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PointsPage()));
              },
              subtitle: 'pts',
            ),
            const SizedBox(height: 20),
            _buildMobileWalletCard(
              'E-Wallet',
              AppConstants.formatNumberWithPeso(mydata['wallet']),
              Icons.account_balance_wallet_rounded,
              [primary, Colors.green.shade800],
              () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WalletPage()));
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Points')
                  .where('uid', isEqualTo: mydata.id)
                  .where('scanned', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                final transactionCount = snapshot.data!.docs.length;
                return _buildMobileWalletCard(
                  'Transactions',
                  transactionCount.toString(),
                  Icons.history_rounded,
                  [Colors.orange, Colors.orange.shade800],
                  () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const InventoryPage()));
                  },
                  subtitle: 'txns',
                );
              },
            ),
          ],
        ),
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
                        builder: (context) => const PaymentsPage(),
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
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  width: double.infinity,
                  height: 160,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
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
                                      await FirebaseFirestore.instance
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    TextWidget(
                                                      text: 'Enter PIN',
                                                      fontSize: 18,
                                                      fontFamily: 'Bold',
                                                      color: Colors.black87,
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      icon: const Icon(
                                                          Icons.close),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
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
                                                const SizedBox(height: 20),
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
                                                          'Wrong PIN Code',
                                                          context: context);
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
                                        'Please register your authorized user account',
                                        context: context);
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
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget(
                    text: 'Recent Activity',
                    fontSize: 18,
                    fontFamily: 'Bold',
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const InventoryPage()));
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
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      // .where('scanned', isEqualTo: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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

                    final data = snapshot.requireData;
                    return data.docs.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
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
                                    text: 'No Recent Activity',
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
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Show transaction details
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextWidget(
                                                        text:
                                                            'Transaction Details',
                                                        fontSize: 18,
                                                        fontFamily: 'Bold',
                                                        color: Colors.black87,
                                                      ),
                                                      IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                            Icons.close),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextWidget(
                                                        text: data.docs[index]
                                                                ['pts']
                                                            .toString(),
                                                        fontSize: 38,
                                                        fontFamily: 'Bold',
                                                        color: blue,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8),
                                                        child: TextWidget(
                                                          text: 'pts',
                                                          fontSize: 14,
                                                          color: blue,
                                                          fontFamily: 'Regular',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 15),
                                                  TextWidget(
                                                    text: DateFormat.yMMMd()
                                                        .add_jm()
                                                        .format(data.docs[index]
                                                                ['dateTime']
                                                            .toDate()),
                                                    fontSize: 14,
                                                    fontFamily: 'Medium',
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  ButtonWidget(
                                                    label: 'Close',
                                                    onPressed: () =>
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
                                      shadowColor:
                                          Colors.black.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: Colors.white,
                                      child: SizedBox(
                                        width: 160,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: blue.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.stars_rounded,
                                                  color: blue,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  TextWidget(
                                                    text: data.docs[index]
                                                            ['pts']
                                                        .toString(),
                                                    fontSize: 32,
                                                    fontFamily: 'Bold',
                                                    color: blue,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: TextWidget(
                                                      text: 'pts',
                                                      fontSize: 12,
                                                      fontFamily: 'Bold',
                                                      color: blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              TextWidget(
                                                text: DateFormat.MMMd().format(
                                                    data.docs[index]['dateTime']
                                                        .toDate()),
                                                fontSize: 12,
                                                fontFamily: 'Medium',
                                                color: Colors.grey,
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
            ]))
      ])
    ]));
  }

  final pts = TextEditingController();

  void reloadPointsDialog(String name) {
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
                                  .doc(_currentBusinessId)
                                  .get();

                              if (doc['wallet'] >= int.parse(pts.text)) {
                                // Prepare payment parameters
                                final uid = _currentBusinessId;
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

                                  showToast('Transaction was succesfull!',
                                      context: context);

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
                                  showToast('Payment failed or canceled.',
                                      context: context);
                                  Navigator.pop(context);
                                }
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

  // Desktop Layout with Sidebar
  Widget _buildDesktopLayout(dynamic mydata, bool isDesktop) {
    return Row(
      children: [
        // Sidebar
        Container(
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
                        isActive: true,
                        onTap: () {},
                      ),
                      _buildSidebarItem(
                        icon: Icons.stars_rounded,
                        label: 'Points',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const PointsPage()));
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Wallet',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const WalletPage()));
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.history_rounded,
                        label: 'Inventory',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const InventoryPage()));
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.groups_2_outlined,
                        label: 'Cashiers',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const CashiersScreen()));
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.payment_rounded,
                        label: 'Payments',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const PaymentsPage()));
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 16),
                      _buildSidebarItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: mydata['name'] ?? 'Business User',
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Medium',
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: 'Business Account',
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main Content - Desktop optimized
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Welcome back!',
                            fontSize: 28,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: mydata['name'] ?? 'Business User',
                            fontSize: 16,
                            fontFamily: 'Regular',
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildHeaderButton(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Scan QR',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextWidget(
                                                text: 'Scan QR',
                                                fontSize: 18,
                                                fontFamily: 'Bold',
                                                color: Colors.black87,
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: const Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
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
                                          const SizedBox(height: 20),
                                          TextFieldWidget(
                                            controller: amount,
                                            label: 'Amount',
                                            inputType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                          ),
                                          const SizedBox(height: 20),
                                          ButtonWidget(
                                            label: 'Continue',
                                            onPressed: () async {
                                              final cashierSnap =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Cashiers')
                                                      .doc(pin.text)
                                                      .get();

                                              final cashierUid =
                                                  cashierSnap.data()?['uid'];

                                              if (!cashierSnap.exists ||
                                                  cashierUid !=
                                                      _currentBusinessId) {
                                                showToast('Wrong PIN Code',
                                                    context: context);
                                                pin.clear();
                                                return;
                                              }

                                              final ptsToTransfer = ((double
                                                              .tryParse(amount
                                                                  .text) ??
                                                          0) *
                                                      mydata['ptsconversion'] *
                                                      0.01)
                                                  .toInt();

                                              if (ptsToTransfer <= 0) {
                                                showToast(
                                                    'Please enter a valid amount',
                                                    context: context);
                                                return;
                                              }

                                              Navigator.of(context).pop();
                                              scanQRCode(
                                                ptsToTransfer,
                                                cashierSnap['name'],
                                              );
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
                          ),
                        ],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: !isDesktop,
                    child: const SizedBox(height: 30),
                  ),
                  // Stats Grid - 3 columns
                  Visibility(
                    visible: !isDesktop,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Points')
                            .where('uid', isEqualTo: mydata.id)
                            .where('scanned', isEqualTo: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final transactionCount = snapshot.data!.docs.length;

                          return GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.5,
                            children: [
                              _buildStatCard(
                                title: 'Points Inventory',
                                value: '${mydata['pts']}',
                                subtitle: 'pts',
                                icon: Icons.stars_rounded,
                                gradient: [blue, Colors.blue.shade800],
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const PointsPage()));
                                },
                              ),
                              _buildStatCard(
                                title: 'E-Wallet',
                                value: AppConstants.formatNumberWithPeso(
                                    mydata['wallet']),
                                subtitle: '',
                                icon: Icons.account_balance_wallet_rounded,
                                gradient: [primary, Colors.green.shade800],
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const WalletPage()));
                                },
                              ),
                              _buildStatCard(
                                title: 'Transactions',
                                value: transactionCount.toString(),
                                subtitle: 'txns',
                                icon: Icons.history_rounded,
                                gradient: [
                                  Colors.orange,
                                  Colors.orange.shade800
                                ],
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const InventoryPage()));
                                },
                              ),
                            ],
                          );
                        }),
                  ),
                  const SizedBox(height: 30),
                  // Rest of content in mobile layout
                  _buildMobileLayout(mydata),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: TextWidget(
        text: label,
        fontSize: 14,
        color: Colors.white,
        fontFamily: 'Medium',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: title,
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Medium',
                  ),
                  Icon(icon, color: Colors.white70, size: 24),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextWidget(
                      text: value,
                      fontSize: 32,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: TextWidget(
                        text: subtitle,
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'Regular',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
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

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            TextWidget(
              text: label,
              fontSize: 12,
              fontFamily: 'Medium',
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileWalletCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.7), size: 18),
              ],
            ),
            const SizedBox(height: 20),
            TextWidget(
              text: title,
              fontSize: 14,
              fontFamily: 'Medium',
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: value,
              fontSize: 32,
              fontFamily: 'Bold',
              color: Colors.white,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              TextWidget(
                text: subtitle,
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
