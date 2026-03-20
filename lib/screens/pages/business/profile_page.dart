import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/transaction_receipt_dialog.dart';

class ProfikePage extends StatelessWidget {
  final dynamic data;

  ProfikePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                TextWidget(
                  text: 'Business Info',
                  fontSize: 18,
                ),
                const SizedBox(
                  width: 50,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Icon(
              Icons.account_circle_outlined,
              color: blue,
              size: 125,
            ),
            TextWidget(
              text: data['name'],
              fontSize: 18,
              color: Colors.black,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Card(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  tileColor: Colors.white,
                  leading: TextWidget(
                    text: 'Points balance',
                    fontSize: 13,
                    color: blue,
                    fontFamily: 'Medium',
                  ),
                  trailing: TextWidget(
                    text: ' ${data['pts']} points',
                    fontSize: 16,
                    color: primary,
                    fontFamily: 'Bold',
                  ),
                ),
              ),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, right: 20),
            //   child: Card(
            //     child: ListTile(
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(
            //           15,
            //         ),
            //       ),
            //       tileColor: Colors.white,
            //       leading: TextWidget(
            //         text: 'Points Receive',
            //         fontSize: 13,
            //         color: blue,
            //         fontFamily: 'Medium',
            //       ),
            //       trailing: TextWidget(
            //         text: ' ${data['ptsreceive']} points',
            //         fontSize: 16,
            //         color: primary,
            //         fontFamily: 'Bold',
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'All Transactions',
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Points')
                          .where('uid',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                        final docs = data.docs.toList();
                        docs.sort((a, b) {
                          final dynamic aRaw = a['dateTime'];
                          final dynamic bRaw = b['dateTime'];
                          final DateTime aTime = aRaw is Timestamp
                              ? aRaw.toDate()
                              : DateTime(2000);
                          final DateTime bTime = bRaw is Timestamp
                              ? bRaw.toDate()
                              : DateTime(2000);
                          return bTime.compareTo(aTime);
                        });

                        return SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final dynamic rawPts = doc['pts'];
                              final double points =
                                  rawPts is num ? rawPts.toDouble() : 0;
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ListTile(
                                  onTap: () {
                                    TransactionReceiptDialog.showPointsReceipt(
                                        context, doc);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: DateFormat.yMMMd()
                                            .add_jm()
                                            .format(doc['dateTime'].toDate()),
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
                                        text: '${doc['type']}',
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
          ],
        ),
      ),
    );
  }

  String incrementIfEndsWith49Or99(double number) {
    int wholeNumberPart = number.round();
    if (wholeNumberPart % 100 == 99 || wholeNumberPart % 100 == 49) {
      return (number + 1).toStringAsFixed(0);
    }
    return number.toStringAsFixed(0);
  }
}
