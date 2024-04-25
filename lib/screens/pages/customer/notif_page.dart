import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerNotifPage extends StatelessWidget {
  const CustomerNotifPage({super.key});

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
                  text: 'Notification',
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
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notifs')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print('error');
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
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Recent',
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: data.docs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Card(
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    tileColor: Colors.white,
                                    trailing: const Icon(
                                      Icons.arrow_circle_down_outlined,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'February 2, 2024, 7:14 PM',
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontFamily: 'Medium',
                                        ),
                                        TextWidget(
                                          text: 'Bought 25 points',
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'Medium',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
