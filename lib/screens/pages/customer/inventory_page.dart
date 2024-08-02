import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/pages/customer/myslots_screen.dart';
import 'package:juan_million/services/add_history.dart';
import 'package:juan_million/services/add_points.dart';
import 'package:juan_million/services/add_wallet.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerInventoryPage extends StatefulWidget {
  const CustomerInventoryPage({super.key});

  @override
  State<CustomerInventoryPage> createState() => _CustomerInventoryPageState();
}

class _CustomerInventoryPageState extends State<CustomerInventoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    checkPoints(7999);
    super.initState();
  }

  final searchController = TextEditingController();
  String nameSearched = '';

  int position = 0;
  int total = 0;

  void checkPoints(int limit) async {
    // if (points < 0) {
    //   FirebaseFirestore.instance
    //       .collection('Community Wallet')
    //       .doc('wallet')
    //       .update({
    //     'pts': points.abs(),
    //   });
    // }

    var document1 = FirebaseFirestore.instance.doc('Community Wallet/wallet');
    var snapshot1 = await document1.get();
    if (snapshot1.data()!['pts'] > limit) {
      await FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet')
          .update({
        // 'wallet': FieldValue.increment(total),
        'pts': FieldValue.increment(-7999),
      }).whenComplete(() async {
        var document = FirebaseFirestore.instance.doc('Users/$uid');
        var snapshot = await document.get();

        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'wallet': FieldValue.increment(5500),
          // 'pts': FieldValue.increment(-total),
        });

        await FirebaseFirestore.instance.collection('Slots').doc(id).delete();

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

        addWallet(5500, '', uid, 'REWARDS 5,500', '');

        addPoints(5500, 1, '', 'REWARDS 5,500');

        addHistory(snapshot.data()!['name'], uid);
      });
    } else {
      print('Points are within the limit.');
    }
  }

  String uid = '';

  String id = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Slots')
                        .where('uid',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          )),
                        );
                      }

                      final data = snapshot.requireData;

                      return Center(
                        child: TextWidget(
                          text: data.docs.length.toString(),
                          fontFamily: 'Bold',
                          fontSize: 75,
                          color: Colors.white,
                        ),
                      );
                    }),
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

                          if (data.docs.isEmpty) {
                            return const Center(child: Text('No slots found'));
                          }

                          int myIndex = 0;

                          for (int i = 0; i < data.docs.length; i++) {
                            if (data.docs[i]['uid'] ==
                                FirebaseAuth.instance.currentUser!.uid) {
                              myIndex = i + 1;
                              break;
                            }
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Your current slot no.',
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              const Expanded(child: SizedBox()),
                              TextWidget(
                                text: '#$myIndex',
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Regular',
                              ),
                              IconButton(
                                onPressed: () {
                                     Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const MySlotsScreen()));
                                },
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Slots')
                              .where('uid',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .where('dateTime',
                                  isGreaterThanOrEqualTo: Timestamp.fromDate(
                                      DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day)))
                              .where('dateTime',
                                  isLessThanOrEqualTo: Timestamp.fromDate(
                                      DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day + 1)
                                          .subtract(
                                              const Duration(seconds: 1))))
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  text: 'Slot Progress',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Bold',
                                ),
                                TextWidget(
                                  text: '${data.docs.length}/5 slots per day',
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Regular',
                                ),
                              ],
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
                              .collection('History')
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

                            return data.docs.isNotEmpty
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Stack(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              StreamBuilder<DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .doc(data.docs[
                                                          data.docs.length -
                                                              1]['uid'])
                                                      .snapshots(),
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot>
                                                          snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const Center(
                                                          child:
                                                              Text('Loading'));
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Center(
                                                          child: Text(
                                                              'Something went wrong'));
                                                    } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                    dynamic mydata =
                                                        snapshot.data;

                                                    return CircleAvatar(
                                                      maxRadius: 40,
                                                      minRadius: 40,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              mydata['pic']),
                                                    );
                                                  }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              TextWidget(
                                                text: data.docs[
                                                        data.docs.length - 1]
                                                    ['name'],
                                                fontSize: 18,
                                                fontFamily: 'Bold',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox();
                          }),
                      const SizedBox(
                        height: 20,
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

                            // for (int i = 0; i < data.docs.length; i++) {
                            //   if (data.docs[i]['uid'] ==
                            //       FirebaseAuth.instance.currentUser!.uid) {
                            //     WidgetsBinding.instance
                            //         .addPostFrameCallback((timeStamp) {
                            //       if (position == 0) {
                            //         setState(() {});
                            //       }

                            //       position++;
                            //     });
                            //   }
                            // }

                            return SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount:
                                    data.docs.length > 9 ? 9 : data.docs.length,
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
