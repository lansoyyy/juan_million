import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/pages/business/packages_payment_page.dart';
import 'package:juan_million/screens/pages/payment_selection_screen.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';

class PackagePage extends StatefulWidget {
  String id;

  PackagePage({
    super.key,
    required this.id,
  });

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  text: 'Packages',
                  fontSize: 18,
                ),
                const SizedBox(
                  width: 50,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Package Deals',
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Packages')
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
                          height: 500,
                          child: ListView.builder(
                            itemCount: data.docs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  child: Card(
                                    elevation: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                      ),
                                      width: double.infinity,
                                      height: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/images/Juan4All 2.png',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: AppConstants
                                                      .formatNumberWithPeso(
                                                          data.docs[index]
                                                              ['price']),
                                                  fontSize: 24,
                                                  color: blue,
                                                  fontFamily: 'Bold',
                                                ),
                                                TextWidget(
                                                  text:
                                                      'Initial load: ${data.docs[index]['wallet']}',
                                                  fontSize: 12,
                                                  color: grey,
                                                  fontFamily: 'Medium',
                                                ),
                                                TextWidget(
                                                  text:
                                                      'Registration Fee: ${data.docs[index]['registrationFee']}',
                                                  fontSize: 12,
                                                  color: grey,
                                                  fontFamily: 'Medium',
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                ButtonWidget(
                                                  radius: 100,
                                                  height: 30,
                                                  width: 75,
                                                  fontSize: 12,
                                                  label: 'Select',
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PackagesPaymentPage(
                                                                  id: widget.id,
                                                                  data: data
                                                                          .docs[
                                                                      index],
                                                                )));
                                                  },
                                                ),
                                              ],
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
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
