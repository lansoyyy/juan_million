import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/services/add_cashier.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

import '../../../utlis/colors.dart';
import '../../../widgets/text_widget.dart';

class CashiersScreen extends StatefulWidget {
  const CashiersScreen({super.key});

  @override
  State<CashiersScreen> createState() => _CashiersScreenState();
}

class _CashiersScreenState extends State<CashiersScreen> {
  final name = TextEditingController();
  final pin = TextEditingController();
  final position = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: TextWidget(
          text: 'Account Users',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Medium',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: 'Screen Description',
                                fontSize: 18,
                                fontFamily: 'Bold',
                                color: Colors.black87,
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextWidget(
                              text:
                                  'Enroll users with a personal 4-digit PIN—each transaction will be securely tracked and linked to the right person.',
                              fontSize: 14,
                              maxLines: 5,
                              align: TextAlign.center,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Add New User',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Name',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        prefixIcon: Icons.person_3_outlined,
                        isRequred: false,
                        controller: name,
                        label: 'Name',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Position',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        prefixIcon: Icons.work_outline,
                        isRequred: false,
                        controller: position,
                        label: 'Position',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFieldWidget(
                        maxLength: 4,
                        showEye: true,
                        isObscure: true,
                        fontStyle: FontStyle.normal,
                        hint: 'PIN Code',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        height: 75,
                        prefixIcon: Icons.lock,
                        isRequred: false,
                        controller: pin,
                        label: 'PIN Code',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ButtonWidget(
                        label: 'Create User',
                        onPressed: () {
                          addCashier(name.text, pin.text, position.text);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: blue,
        elevation: 4,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Cashiers')
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
                  return data.docs.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_off_outlined,
                                    color: blue,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextWidget(
                                  text: 'No Account Users Yet',
                                  fontSize: 18,
                                  fontFamily: 'Bold',
                                  color: Colors.black87,
                                ),
                                const SizedBox(height: 10),
                                TextWidget(
                                  text:
                                      'Tap the + button to add your first user',
                                  fontSize: 14,
                                  fontFamily: 'Regular',
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.builder(
                              itemCount: data.docs.length,
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  child: Card(
                                    elevation: 5,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: blue.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.person_3_outlined,
                                              color: blue,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: data.docs[index]
                                                      ['name'],
                                                  fontSize: 16,
                                                  fontFamily: 'Bold',
                                                  color: Colors.black87,
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: blue
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: TextWidget(
                                                        text: data.docs[index]
                                                            ['position'],
                                                        fontSize: 12,
                                                        color: blue,
                                                        fontFamily: 'Medium',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              // Show confirmation dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    title: TextWidget(
                                                      text: 'Delete User',
                                                      fontSize: 18,
                                                      fontFamily: 'Bold',
                                                      color: Colors.black87,
                                                    ),
                                                    content: TextWidget(
                                                      text:
                                                          'Are you sure you want to delete this user?',
                                                      fontSize: 14,
                                                      fontFamily: 'Regular',
                                                      color: Colors.grey,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: TextWidget(
                                                          text: 'Cancel',
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                          fontFamily: 'Medium',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Cashiers')
                                                              .doc(data
                                                                  .docs[index]
                                                                  .id)
                                                              .delete();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: TextWidget(
                                                          text: 'Delete',
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                })
          ],
        ),
      ),
    );
  }
}
