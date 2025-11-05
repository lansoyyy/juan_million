import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanner_screen.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CustomerWalletPage extends StatefulWidget {
  const CustomerWalletPage({super.key});

  @override
  State<CustomerWalletPage> createState() => _CustomerWalletPageState();
}

class _CustomerWalletPageState extends State<CustomerWalletPage> {
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
"Welcome to your E-Wallet! Use your cash earnings to shop with our affiliate stores, buy booster points, or cash out at the nearest partner store."

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

  // Wallet-specific gradient colors
  final Color walletPrimary = const Color(0xFF6a11cb);
  final Color walletSecondary = const Color(0xFF2575fc);

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
                // Modern Gradient Header (Purple/Blue theme for wallet)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [walletPrimary, walletSecondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: walletPrimary.withOpacity(0.3),
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
                                text: 'E-Wallet',
                                fontSize: isDesktop ? 28 : 24,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Wallet Balance Display
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
                                  text: 'Available Balance',
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Medium',
                                ),
                                const SizedBox(height: 15),
                                TextWidget(
                                  text: AppConstants.formatNumberWithPeso(
                                      data['wallet']),
                                  fontFamily: 'Bold',
                                  fontSize: isDesktop ? 80 : 70,
                                  color: Colors.white,
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
                                                text: 'Transfer Money',
                                                fontSize: 20,
                                                fontFamily: 'Bold',
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    selected = 'Business';
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
                                                        walletPrimary,
                                                        walletSecondary
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.business_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                title: TextWidget(
                                                  text: 'To Affiliate',
                                                  fontSize: 16,
                                                  fontFamily: 'Bold',
                                                ),
                                                subtitle: TextWidget(
                                                  text:
                                                      'Transfer money to affiliate store',
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
                                    colors: [walletPrimary, walletSecondary]),
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
                                  .collection('Wallets')
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

                                // Filter transactions for current user
                                final userTransactions = data.docs
                                    .where((doc) =>
                                        doc['uid'] ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid ||
                                        doc['from'] ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid)
                                    .toList();

                                if (userTransactions.isEmpty) {
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
                                        itemCount: userTransactions.length,
                                        itemBuilder: (context, index) {
                                          final transaction =
                                              userTransactions[index];
                                          return _buildTransactionCard(
                                              transaction, true);
                                        },
                                      )
                                    : ListView.builder(
                                        itemCount: userTransactions.length,
                                        itemBuilder: (context, index) {
                                          final transaction =
                                              userTransactions[index];
                                          return _buildTransactionCard(
                                              transaction, false);
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

  Widget _buildTransactionCard(dynamic transaction, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: walletPrimary.withOpacity(0.1), width: 1),
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
                walletPrimary.withOpacity(0.2),
                walletSecondary.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: walletPrimary,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: AppConstants.formatNumberWithPeso(transaction['pts']),
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

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot['pts'] >= int.parse(pts.text)) {
          DocumentSnapshot doc1 = await FirebaseFirestore.instance
              .collection('Users')
              .doc(result)
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
                  .doc(result)
                  .update({
                'pts': FieldValue.increment(int.parse(pts.text)),
              }).whenComplete(
                () {
                  addWallet(
                      int.parse(pts.text),
                      result,
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
                  .doc(result)
                  .update({
                'wallet': FieldValue.increment(int.parse(pts.text)),
              }).whenComplete(
                () {
                  addWallet(
                      int.parse(pts.text),
                      result,
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
        }
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }
}
