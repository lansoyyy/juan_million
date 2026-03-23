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
                stream: FirebaseFirestore.instance
                    .collection('Slots')
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
                  final sortedSlots = data.docs.toList()
                    ..sort((a, b) {
                      final dynamic aRaw = a['dateTime'];
                      final dynamic bRaw = b['dateTime'];
                      final DateTime aTime = aRaw is Timestamp
                          ? aRaw.toDate()
                          : DateTime(2000);
                      final DateTime bTime = bRaw is Timestamp
                          ? bRaw.toDate()
                          : DateTime(2000);
                      return aTime.compareTo(bTime);
                    });

                  final userSlots = <MapEntry<int, QueryDocumentSnapshot>>[];
                  for (int index = 0; index < sortedSlots.length; index++) {
                    final slotDoc = sortedSlots[index];
                    if (slotDoc['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                      userSlots.add(MapEntry(index + 1, slotDoc));
                    }
                  }

                  if (userSlots.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No slots purchased yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: userSlots.length,
                      itemBuilder: (context, index) {
                        final slotEntry = userSlots[index];
                        final int userSlotNumber = slotEntry.key;
                        final slotDoc = slotEntry.value;

                        return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(slotDoc['uid'])
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                    height: 60,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              } else if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Something went wrong'));
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                    height: 60,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }

                              final mydata = snapshot.data!.data()
                                  as Map<String, dynamic>?;
                              if (mydata == null) return const SizedBox();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
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
                                              mydata['pic'] != null &&
                                                      mydata['pic'].isNotEmpty
                                                  ? NetworkImage(mydata['pic'])
                                                  : null,
                                          child: mydata['pic'] == null ||
                                                  mydata['pic'].isEmpty
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: TextWidget(
                                            text: mydata['name'] ?? 'Unknown',
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: 'Bold',
                                          ),
                                        ),
                                        TextWidget(
                                          text: '#$userSlotNumber',
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontFamily: 'Bold',
                                        ),
                                        const SizedBox(
                                          width: 10,
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
