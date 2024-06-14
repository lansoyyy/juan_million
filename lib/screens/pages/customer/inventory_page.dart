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
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      backgroundColor: secondary,
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
            return SafeArea(
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
                        text: 'Bayanihan Fund',
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
                            text: 'Current Slot',
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
                                text:
                                    '${double.parse((mydata['pts'] / 50).toString()).toStringAsFixed(0)}/10 per day',
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                          TextWidget(
                            text:
                                '${(double.parse((mydata['pts'] / 50).toString()) * 10).toStringAsFixed(0)}%',
                            fontSize: 12,
                            color: Colors.black,
                            fontFamily: 'Regular',
                          ),
                          LinearProgressIndicator(
                            minHeight: 12,
                            color: primary,
                            value:
                                double.parse((mydata['pts'] / 50).toString()) *
                                    0.1,
                            backgroundColor: Colors.grey,
                          ),

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
                          // Center(
                          //   child: TextWidget(
                          //     text: 'No Slots',
                          //     fontSize: 14,
                          //     fontFamily: 'Regular',
                          //     color: Colors.grey,
                          //   ),
                          // ),
                          // StreamBuilder<QuerySnapshot>(
                          //     stream: FirebaseFirestore.instance
                          //         .collection('Users')
                          //         .where('pts', isGreaterThanOrEqualTo: 50)
                          //         .snapshots(),
                          //     builder: (BuildContext context,
                          //         AsyncSnapshot<QuerySnapshot> snapshot) {
                          //       if (snapshot.hasError) {
                          //         print(snapshot.error);
                          //         return const Center(child: Text('Error'));
                          //       }
                          //       if (snapshot.connectionState ==
                          //           ConnectionState.waiting) {
                          //         return const Padding(
                          //           padding: EdgeInsets.only(top: 50),
                          //           child: Center(
                          //               child: CircularProgressIndicator(
                          //             color: Colors.black,
                          //           )),
                          //         );
                          //       }

                          //       final data = snapshot.requireData;
                          //       return Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceEvenly,
                          //         children: [
                          //           for (int i = 0; i < data.docs.length; i++)
                          //             Stack(
                          //               children: [
                          //                 Column(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.center,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.center,
                          //                   children: [
                          //                     CircleAvatar(
                          //                       maxRadius: 40,
                          //                       minRadius: 40,
                          //                       backgroundImage: NetworkImage(
                          //                           data.docs[i]['pic']),
                          //                       child: Padding(
                          //                         padding:
                          //                             const EdgeInsets.only(
                          //                                 top: 20),
                          //                         child: Align(
                          //                           alignment:
                          //                               Alignment.bottomCenter,
                          //                           child: Container(
                          //                             height: 25,
                          //                             width: 25,
                          //                             decoration:
                          //                                 const BoxDecoration(
                          //                               shape: BoxShape.circle,
                          //                               color: Colors.white,
                          //                             ),
                          //                             child: Center(
                          //                               child: TextWidget(
                          //                                 text: '${i + 1}',
                          //                                 fontSize: 12,
                          //                                 fontFamily: 'Bold',
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                     const SizedBox(
                          //                       height: 5,
                          //                     ),
                          //                     TextWidget(
                          //                       text: data.docs[i]['name'],
                          //                       fontSize: 18,
                          //                       fontFamily: 'Bold',
                          //                       color: Colors.white,
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ],
                          //             ),
                          //         ],
                          //       );
                          //     }),

                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .orderBy('pts')
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
                                      if (data.docs[index].id ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((timeStamp) {
                                          if (position == 0) {
                                            setState(() {});
                                          }
                                          position = index + 1;
                                        });
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          tileColor: Colors.white,
                                          leading: SizedBox(
                                            height: 50,
                                            width: 300,
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
                                                  backgroundImage: NetworkImage(
                                                      data.docs[index]['pic']),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                TextWidget(
                                                  text: data.docs[index]
                                                      ['name'],
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: 'Bold',
                                                ),
                                                const Expanded(
                                                  child: SizedBox(
                                                    width: 20,
                                                  ),
                                                ),
                                                TextWidget(
                                                  text:
                                                      '${data.docs[index]['pts']}pts',
                                                  fontSize: 14,
                                                  color: secondary,
                                                  fontFamily: 'Bold',
                                                ),
                                              ],
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
                  ],
                ),
              ),
            );
          }),
    );
  }
}
