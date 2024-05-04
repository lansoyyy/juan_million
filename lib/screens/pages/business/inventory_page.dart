import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final searchController = TextEditingController();
  String nameSearched = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Points')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('scanned', isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      text: 'Inventory',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                    child: TextWidget(
                      text: data.docs.length.toString(),
                      fontFamily: 'Bold',
                      fontSize: 75,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        TextWidget(
                          text: 'Customers',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        TextWidget(
                          text: DateFormat.yMMMd().format(DateTime.now()),
                          fontSize: 12,
                          color: Colors.grey,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: 'Name',
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: TextWidget(
                                  text: 'Points Balance',
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'Bold',
                                ),
                              ),
                              TextWidget(
                                text: 'Points Redeemed',
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: data.docs.length,
                            itemBuilder: (context, index) {
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(data.docs[index]['scannedId'])
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: Text('Loading'));
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child: Text('Something went wrong'));
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    dynamic userData = snapshot.data;
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
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              TextWidget(
                                                text: userData['name'],
                                                fontSize: 11,
                                                color: Colors.black,
                                                fontFamily: 'Medium',
                                              ),
                                              TextWidget(
                                                text:
                                                    userData['pts'].toString(),
                                                fontSize: 11,
                                                color: Colors.black,
                                                fontFamily: 'Medium',
                                              ),
                                              TextWidget(
                                                text: data.docs[index]['pts']
                                                    .toString(),
                                                fontSize: 11,
                                                color: Colors.black,
                                                fontFamily: 'Medium',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
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
