import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/business/myqr_page.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      backgroundColor: primary,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: TextWidget(
                      text: 'Wallet',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                    child: TextWidget(
                      text: data['wallet'].toString(),
                      fontFamily: 'Bold',
                      fontSize: 75,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      width: double.infinity,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const MyQRBusinessPage()));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.sync_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                TextWidget(
                                  text: 'Transfer',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: VerticalDivider(
                              color: Colors.white,
                              thickness: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => StorePage(
                                        inbusiness: true,
                                      )));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wallet,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                TextWidget(
                                  text: 'Top up',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Transactions',
                          fontSize: 18,
                          color: Colors.white,
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
                                height: 300,
                                child: ListView.builder(
                                  itemCount: data.docs.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: ListTile(
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
                                                  .format(data.docs[index]
                                                          ['dateTime']
                                                      .toDate()),
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontFamily: 'Medium',
                                            ),
                                            TextWidget(
                                              text:
                                                  'Transferred ${data.docs[index]['pts']} amount',
                                              fontSize: 16,
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
            );
          }),
    );
  }
}
