import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class PaymentSelectionScreen extends StatefulWidget {
  dynamic item;

  bool? inbusiness;

  PaymentSelectionScreen({
    super.key,
    required this.item,
    this.inbusiness = false,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection(widget.inbusiness! ? 'Business' : 'Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.black,
                            )),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PaymentScreen()));
                    },
                    child: Card(
                      elevation: 3,
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment,
                              size: 150,
                              color: blue,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextWidget(
                              text: 'Payment Gateway',
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (data['wallet'] > widget.item['price']) {
                        addPoints(widget.item['slots'] * 150, 1);
                        Navigator.of(context).pop();

                        showToast('Succesfully purchased!');

                        // Check if business
                        await FirebaseFirestore.instance
                            .collection(
                                widget.inbusiness! ? 'Business' : 'Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'pts':
                              FieldValue.increment(widget.item['slots'] * 150),
                          'wallet': FieldValue.increment(
                              -(widget.item['slots'] * 150)),
                        });
                      } else {
                        showToast('Not enough balance on wallet!');
                      }
                    },
                    child: Card(
                      elevation: 3,
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wallet,
                              size: 150,
                              color: blue,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextWidget(
                              text: 'Pay with Wallet',
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
