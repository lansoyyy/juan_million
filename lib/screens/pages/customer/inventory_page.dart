import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerInventoryPage extends StatefulWidget {
  const CustomerInventoryPage({super.key});

  @override
  State<CustomerInventoryPage> createState() => _CustomerInventoryPageState();
}

class _CustomerInventoryPageState extends State<CustomerInventoryPage> {
  final searchController = TextEditingController();
  String nameSearched = '';

  int position = 0;
  int total = 0;

  void checkPoints(int points, int limit) async {
    if (points > limit) {
      int total = points - limit;

      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'wallet': FieldValue.increment(total),
        // 'pts': FieldValue.increment(-total),
      });

      await FirebaseFirestore.instance.collection('Slots').doc(id).delete();

      await FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet')
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(-limit),
      });
      await FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('business')
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(2400),
      });
      await FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('it')
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(100),
      });
    } else {
      print('Points are within the limit.');
    }
  }

  String uid = '';

  String id = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: secondary,
        body: SafeArea(
          child: SingleChildScrollView(
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
                    text: 'Community Wallet',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Center(
                  child: TextWidget(
                    text: position.toString(),
                    fontFamily: 'Bold',
                    fontSize: 75,
                    color: Colors.white,
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      TextWidget(
                        text: 'Current Slot/s',
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Slot Progress',
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                          TextWidget(
                            text: '$position/10 slots per day',
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Community Wallet')
                              .doc('wallet')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: Text('Loading'));
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Something went wrong'));
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            dynamic walletdata = snapshot.data;

                            checkPoints(walletdata['pts'], 8000);
                            return TextWidget(
                              text: '${walletdata['pts']}/8000 pts',
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Regular',
                            );
                          }),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Community Wallet')
                              .doc('wallet')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: Text('Loading'));
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Something went wrong'));
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            dynamic walletdata = snapshot.data;
                            return LinearProgressIndicator(
                              minHeight: 12,
                              color: primary,
                              value: double.parse(
                                      (walletdata['pts'] / 8000).toString()) *
                                  1,
                              backgroundColor: Colors.grey,
                            );
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      TextWidget(
                        text: 'Community',
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Slots')
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

                            if (data.docs.isNotEmpty) {
                              uid = data.docs.first['uid'];
                              id = data.docs.first.id;
                            }

                            for (int i = 0; i < data.docs.length; i++) {
                              if (data.docs[i]['uid'] ==
                                  FirebaseAuth.instance.currentUser!.uid) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  if (position == 0) {
                                    setState(() {});
                                  }

                                  position++;
                                });
                              }
                            }

                            return SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount: data.docs.length > 10
                                    ? 10
                                    : data.docs.length,
                                itemBuilder: (context, index) {
                                  return StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(data.docs[index]['uid'])
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                              child: Text('Loading'));
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                              child:
                                                  Text('Something went wrong'));
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        dynamic mydata = snapshot.data;
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  TextWidget(
                                                    text: '${index + 1}',
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontFamily: 'Bold',
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  CircleAvatar(
                                                    maxRadius: 20,
                                                    minRadius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            mydata['pic']),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  TextWidget(
                                                    text: mydata['name'],
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontFamily: 'Bold',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
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
        ));
  }
}
