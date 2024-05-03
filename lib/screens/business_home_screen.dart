import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/qr_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
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
            dynamic mydata = snapshot.data;
            return Column(
              children: [
                SizedBox(
                  height: 250,
                  width: 500,
                  child: ListView.builder(
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const PointsPage()));
                          } else if (index == 1) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const WalletPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const InventoryPage()));
                          }
                        },
                        child: Center(
                          child: Container(
                            width: 425,
                            height: 250,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? blue
                                  : index == 1
                                      ? primary
                                      : secondary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(1000),
                                bottomRight: Radius.circular(1000),
                              ),
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 5),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        TextWidget(
                                          text: 'Hello ka-Juan!',
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        const Expanded(
                                          child: SizedBox(),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const QRPage()));
                                          },
                                          icon: const Icon(
                                            Icons.qr_code,
                                            color: Colors.white,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SettingsPage()));
                                          },
                                          icon: const Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextWidget(
                                      text: index == 0
                                          ? 'Total Points'
                                          : index == 1
                                              ? 'Wallet'
                                              : 'Customers',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          text: '${mydata['pts']}',
                                          fontFamily: 'Bold',
                                          fontSize: 50,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        index == 0
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle),
                                                child: index == 0
                                                    ? const Icon(
                                                        Icons.add,
                                                        color: Colors.black,
                                                      )
                                                    : const SizedBox(),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    index == 2
                                        ? TextWidget(
                                            text: '0 Slots',
                                            fontSize: 14,
                                            color: Colors.white,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget(
                            text: 'Store',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const StorePage()));
                            },
                            child: TextWidget(
                              text: 'See all',
                              color: blue,
                              fontSize: 14,
                              fontFamily: 'Bold',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Boosters')
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
                              height: 150,
                              width: 500,
                              child: ListView.builder(
                                itemCount: data.docs.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Card(
                                      elevation: 5,
                                      color: Colors.white,
                                      child: SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text:
                                                    'P${data.docs[index]['price']}',
                                                fontSize: 14,
                                                fontFamily: 'Medium',
                                                color: blue,
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextWidget(
                                                    text:
                                                        '${data.docs[index]['slots'] * 150}',
                                                    fontSize: 38,
                                                    fontFamily: 'Bold',
                                                    color: blue,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextWidget(
                                                    text: 'pts',
                                                    fontSize: 12,
                                                    fontFamily: 'Bold',
                                                    color: blue,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: secondary,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextWidget(
                                                    text: 'Limited offer',
                                                    fontSize: 10,
                                                    fontFamily: 'Bold',
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          })
                    ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget(
                            text: 'Promo & Deals',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const StorePage()));
                            },
                            child: TextWidget(
                              text: 'See all',
                              color: blue,
                              fontSize: 14,
                              fontFamily: 'Bold',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Boosters')
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
                              height: 150,
                              width: 500,
                              child: ListView.builder(
                                itemCount: 2,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Card(
                                      elevation: 5,
                                      color: Colors.white,
                                      child: SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text:
                                                    'P${data.docs[index]['price']}',
                                                fontSize: 14,
                                                fontFamily: 'Medium',
                                                color: blue,
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextWidget(
                                                    text:
                                                        '${data.docs[index]['slots'] * 150}',
                                                    fontSize: 38,
                                                    fontFamily: 'Bold',
                                                    color: blue,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextWidget(
                                                    text: 'pts',
                                                    fontSize: 12,
                                                    fontFamily: 'Bold',
                                                    color: blue,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: secondary,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextWidget(
                                                    text: 'Limited offer',
                                                    fontSize: 10,
                                                    fontFamily: 'Bold',
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
