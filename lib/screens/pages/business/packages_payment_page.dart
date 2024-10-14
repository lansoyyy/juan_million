import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class PackagesPaymentPage extends StatefulWidget {
  dynamic data;
  String id;

  PackagesPaymentPage({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<PackagesPaymentPage> createState() => _PackagesPaymentPageState();
}

class _PackagesPaymentPageState extends State<PackagesPaymentPage> {
  @override
  Widget build(BuildContext context) {
    int qty = 1;
    return Scaffold(
        body: SafeArea(
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
          // const SizedBox(
          //   height: 20,
          // ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) => const PaymentScreen()));
          //   },
          //   child: Card(
          //     elevation: 3,
          //     child: SizedBox(
          //       height: 200,
          //       width: 300,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.payment,
          //             size: 150,
          //             color: blue,
          //           ),
          //           const SizedBox(
          //             height: 5,
          //           ),
          //           TextWidget(
          //             text: 'Payment Gateway',
          //             fontSize: 14,
          //             fontFamily: 'Regular',
          //             color: blue,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 25,
          ),
          GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Dialog(
                    child: StatefulBuilder(builder: (context, setState) {
                      return SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextWidget(
                                text:
                                    'To activate complete your payment to the Area Coordinator',
                                fontSize: 14,
                                maxLines: 3,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ButtonWidget(
                                width: 225,
                                label: 'Continue',
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Business')
                                      .doc(widget.id)
                                      .update({
                                    'packagePayment': widget.data['price'],
                                    'packageWallet': widget.data['wallet'],
                                  }).whenComplete(() {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen(
                                                inCustomer: false,
                                              )),
                                      (route) {
                                        return false;
                                      },
                                    );
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              );
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
                      text: 'Pay with Cash',
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
    ));
  }
}
