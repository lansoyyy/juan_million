import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final dynamic item;

  final bool inbusiness;

  PaymentSelectionScreen({
    super.key,
    required this.item,
    this.inbusiness = false,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  int _earnedPointsForQty(int qty) {
    final dynamic rawSlots = widget.item['slots'];
    final double slots = rawSlots is num ? rawSlots.toDouble() : 0.0;

    final int basePoints =
        (slots == 0.066 ? (0.0665 * 150) : (slots * 150)).round();
    return basePoints * qty;
  }

  int _totalCostForQty(int qty) {
    final dynamic rawPrice = widget.item['price'];
    final int price = rawPrice is num
        ? rawPrice.toDouble().round()
        : int.tryParse('$rawPrice') ?? 0;
    final int discount = (price * 0.10).toInt() * qty;
    return (price * qty) - discount;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection(widget.inbusiness ? 'Business' : 'Users')
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
    final slotsSnapshot = await FirebaseFirestore.instance
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
        .get();

    final int currentSlots = slotsSnapshot.docs.length;
    final int slotsLeft = 5 - currentSlots;

    if (slotsLeft < widget.item['slots'].round() * qty) {
      showToast("You've reached the maximum slots as of today!",
          context: context);
      return;
    }

    final int totalCost = _totalCostForQty(qty);
    if ((data['wallet'] is num ? (data['wallet'] as num).toInt() : 0) <
        totalCost) {
      showToast('Not enough balance on wallet!', context: context);
      return;
    }

    final int earnedPoints = _earnedPointsForQty(qty);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ownerCollection = widget.inbusiness ? 'Business' : 'Users';
    final ownerRef =
        FirebaseFirestore.instance.collection(ownerCollection).doc(userId);
    final communityRef =
        FirebaseFirestore.instance.collection('Community Wallet').doc('wallet');
    final pointsDoc = FirebaseFirestore.instance.collection('Points').doc();
    final walletDoc = FirebaseFirestore.instance.collection('Wallets').doc();

    final batch = FirebaseFirestore.instance.batch();
    batch.update(communityRef, {
      'pts': FieldValue.increment(earnedPoints),
    });
    batch.update(ownerRef, {
      'pts': FieldValue.increment(earnedPoints),
      'wallet': FieldValue.increment(-totalCost),
    });
    batch.set(pointsDoc, {
      'pts': earnedPoints,
      'qty': qty,
      'cashier': '',
      'uid': userId,
      'id': pointsDoc.id,
      'scanned': true,
      'scannedId': userId,
      'dateTime': DateTime.now(),
      'type': 'Points converted to Slots',
    });
    batch.set(walletDoc, {
      'pts': totalCost,
      'from': userId,
      'uid': userId,
      'id': walletDoc.id,
      'dateTime': DateTime.now(),
      'type': 'Purchase points',
      'cashier': '',
    });
    await batch.commit();

    showToast('Succesfully purchased!', context: context);
    Navigator.of(context).pop();
  }
}
