import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    checkPoints(4163);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWidget(
                      text: 'Screen Description:',
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextWidget(
                      text: '''
"This screen shows how many bonus slots you have. To check your current position, click the Slots menu. You can also track sequence updates and see who received the bonus prize." 

''',
                      fontSize: 14,
                      maxLines: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        'pts': FieldValue.increment(-4163),
      }).whenComplete(() async {
        var document = FirebaseFirestore.instance.doc('Users/$uid');
        var snapshot = await document.get();

        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'wallet': FieldValue.increment(3500),
          // 'pts': FieldValue.increment(-total),
        });

        await FirebaseFirestore.instance.collection('Slots').doc(id).delete();

        await FirebaseFirestore.instance
            .collection('Community Wallet')
            .doc('business')
            .update({
          // 'wallet': FieldValue.increment(total),
          'pts': FieldValue.increment(478),
        });
        await FirebaseFirestore.instance
            .collection('Community Wallet')
            .doc('it')
            .update({
          // 'wallet': FieldValue.increment(total),
          'pts': FieldValue.increment(185),
        });

        addWallet(3500, '', uid, 'REWARDS 3,500', '');

        addPoints(3500, 1, '', 'REWARDS 3,500', '');

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Modern Gradient Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [secondary, primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: secondary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 30 : 20),
                  child: Column(
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextWidget(
                            text: 'Community Wallet',
                            fontSize: isDesktop ? 28 : 24,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Slots Display
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Slots')
                              .where('uid',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const SizedBox();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                  color: Colors.white);
                            }

                            final data = snapshot.requireData;

                            return Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: data.docs.length.toString(),
                                        fontFamily: 'Bold',
                                        fontSize: isDesktop ? 80 : 70,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Icon(
                                          Icons.confirmation_number_rounded,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextWidget(
                                    text: 'Current Slot/s',
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: 'Bold',
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 30 : 20),
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
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                              const Expanded(child: SizedBox()),
                              TextWidget(
                                text: '#$myIndex',
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Regular',
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const MySlotsScreen()));
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
                                  color: Colors.black,
                                  fontFamily: 'Bold',
                                ),
                                StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Community Wallet')
                                        .doc('wallet')
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
                                            child: CircularProgressIndicator());
                                      }
                                      dynamic walletdata = snapshot.data;
                                      return TextWidget(
                                        text:
                                            '${(double.parse((walletdata['pts'] / 4165).toString()) * 100).toStringAsFixed(0)}%',
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Regular',
                                      );
                                    }),
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
                                      (walletdata['pts'] / 4165).toString()) *
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

                            final itemCount =
                                data.docs.length > 9 ? 9 : data.docs.length;

                            // Desktop: 2-column grid, Mobile: list
                            return SizedBox(
                              height: isDesktop ? 400 : 300,
                              child: isDesktop
                                  ? GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15,
                                        childAspectRatio: 4,
                                      ),
                                      itemCount: itemCount,
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
                                                return const SizedBox();
                                              } else if (snapshot.hasError) {
                                                return const SizedBox();
                                              } else if (snapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                              dynamic mydata = snapshot.data;
                                              return _buildLeaderboardCard(
                                                  index, mydata, true);
                                            });
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: itemCount,
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
                                                    child: Text(
                                                        'Something went wrong'));
                                              } else if (snapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                              dynamic mydata = snapshot.data;
                                              return _buildLeaderboardCard(
                                                  index, mydata, false);
                                            });
                                      },
                                    ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildLeaderboardCard(int index, dynamic userData, bool isDesktop) {
    // Medal colors for top 3
    Color? rankColor;
    IconData? rankIcon;

    if (index == 0) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankIcon = Icons.emoji_events_rounded;
    } else if (index == 1) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankIcon = Icons.emoji_events_rounded;
    } else if (index == 2) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = Icons.emoji_events_rounded;
    }

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rankColor != null
              ? rankColor.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: rankColor != null
                ? rankColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank number or medal
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: rankColor != null
                    ? LinearGradient(
                        colors: [
                          rankColor,
                          rankColor.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                        ],
                      ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rankIcon != null
                    ? Icon(rankIcon, color: Colors.white, size: 20)
                    : TextWidget(
                        text: '${index + 1}',
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
              ),
            ),
            const SizedBox(width: 15),
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(userData['pic']),
            ),
            const SizedBox(width: 15),
            // Name
            Expanded(
              child: TextWidget(
                text: userData['name'],
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Bold',
              ),
            ),
            // Trophy icon for top 3
            if (rankIcon != null)
              Icon(
                Icons.workspace_premium_rounded,
                color: rankColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
