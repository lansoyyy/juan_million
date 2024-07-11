import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
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

    int qty = 1;
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child:
                                StatefulBuilder(builder: (context, setState) {
                              return SizedBox(
                                height: 300,
                                width: 250,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Payment Details',
                                            fontSize: 24,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Merchandise',
                                            fontSize: 12,
                                          ),
                                          TextWidget(
                                            text: AppConstants
                                                .formatNumberWithPeso(
                                                    double.parse((widget
                                                                .item['price'])
                                                            .toString())
                                                        .round()),
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Quantity',
                                            fontSize: 12,
                                          ),
                                          TextWidget(
                                            text: qty.toString(),
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Subtotal',
                                            fontSize: 12,
                                          ),
                                          TextWidget(
                                            text: AppConstants
                                                .formatNumberWithPeso(
                                                    double.parse((widget.item[
                                                                    'price'])
                                                                .toString())
                                                            .round() *
                                                        qty),
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Promo Discount(s) 10%',
                                            fontSize: 12,
                                          ),
                                          TextWidget(
                                            text: AppConstants
                                                .formatNumberWithPeso(((widget
                                                                        .item[
                                                                    'slots'] *
                                                                (widget.item[
                                                                        'price'] /
                                                                    widget.item[
                                                                        'slots'])) *
                                                            0.10)
                                                        .toInt() *
                                                    qty),
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: 'Total',
                                            fontSize: 12,
                                          ),
                                          TextWidget(
                                            text: AppConstants.formatNumberWithPeso(((double
                                                                .parse((widget
                                                                            .item[
                                                                        'price'])
                                                                    .toString())
                                                            .round() *
                                                        qty) -
                                                    (((widget.item['slots'] *
                                                                    (widget.item[
                                                                            'price'] /
                                                                        widget.item[
                                                                            'slots'])) *
                                                                0.10)
                                                            .toInt() *
                                                        qty))
                                                .toInt()),
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                        ],
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
                                            ),
                                          ),
                                          TextWidget(
                                            text: qty.toString(),
                                            fontSize: 18,
                                            fontFamily: 'Bold',
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (widget.item['slots'] ==
                                                  0.066) {
                                                if (qty <= 14) {
                                                  setState(() {
                                                    qty++;
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  qty++;
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ButtonWidget(
                                        width: 225,
                                        label: 'Confirm',
                                        onPressed: () {
                                          Navigator.pop(context);

                                          buypoints(qty, data);
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

  buypoints(int qty, data) async {
    await FirebaseFirestore.instance
        .collection('Slots')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)))
        .where('dateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day + 1)
                .subtract(const Duration(seconds: 1))))
        .get()
        .then((snapshot) async {
      int currentSlots = snapshot.docs.length;
      int slotsLeft = 10 - currentSlots;

      if (slotsLeft >= widget.item['slots'].round() * qty) {
        if (data['wallet'] >=
            ((double.parse((widget.item['price']).toString()).round() * qty) -
                    (((widget.item['slots'] *
                                    (widget.item['price'] /
                                        widget.item['slots'])) *
                                0.10)
                            .toInt() *
                        qty))
                .toInt()) {
          if (widget.item['price'] == 20) {
            await FirebaseFirestore.instance
                .collection('Community Wallet')
                .doc('wallet')
                .update({
              // 'wallet': FieldValue.increment(total),
              'pts': FieldValue.increment(20),
            });
          }

          await FirebaseFirestore.instance
              .collection(widget.inbusiness! ? 'Business' : 'Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'pts': widget.item['slots'] == 0.066
                ? FieldValue.increment(((0.0665 * 150) * qty).round())
                : FieldValue.increment(
                    ((widget.item['slots'] * 150) * qty).round()),
            'wallet': FieldValue.increment(
                -((double.parse((widget.item['price']).toString()).round() *
                            qty) -
                        (((widget.item['slots'] *
                                        (widget.item['price'] /
                                            widget.item['slots'])) *
                                    0.10)
                                .toInt() *
                            qty))
                    .toInt()),
          });
          showToast('Succesfully purchased!');

          addPoints((widget.item['slots'] * 150) * qty, qty, '',
              'Points converted to Slots');
          Navigator.of(context).pop();
        } else {
          showToast('Not enough balance on wallet!');
        }
      } else {
        showToast("You've reached the maximum slots as of today!");
      }
    });
  }
}
