import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class MySlotsScreen extends StatelessWidget {
  const MySlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: Column(
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
            TextWidget(
              text: 'My Slots',
              fontSize: 32,
              color: Colors.white,
              fontFamily: 'Bold',
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Slots').snapshots(),
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

                  // if (data.docs.isNotEmpty) {
                  //   uid = data.docs.first['uid'];
                  //   id = data.docs.first.id;
                  // }

                  return SizedBox(
                    height: 500,
                    child: ListView.builder(
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        // Calculate user's sequential slot number (1, 2, 3, etc.)
                        int userSlotNumber = 0;
                        for (int i = 0; i <= index; i++) {
                          if (data.docs[i]['uid'] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            userSlotNumber++;
                          }
                        }

                        return data.docs[index]['uid'] !=
                                FirebaseAuth.instance.currentUser!.uid
                            ? const SizedBox()
                            : StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(data.docs[index]['uid'])
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
                                  dynamic mydata = snapshot.data;
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              maxRadius: 20,
                                              minRadius: 20,
                                              backgroundImage:
                                                  NetworkImage(mydata['pic']),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            TextWidget(
                                              text: mydata['name'],
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
                                              text: '#$userSlotNumber',
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontFamily: 'Bold',
                                            ),
                                            const SizedBox(
                                              width: 20,
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
    );
  }
}
