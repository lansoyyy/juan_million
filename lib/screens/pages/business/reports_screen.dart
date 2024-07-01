import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/services/add_cashier.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

import '../../../utlis/colors.dart';
import '../../../widgets/text_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final name = TextEditingController();
  final pin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Cashier Name',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        prefixIcon: Icons.person_3_outlined,
                        isRequred: false,
                        controller: name,
                        label: 'Cashier Name',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                        showEye: true,
                        isObscure: true,
                        fontStyle: FontStyle.normal,
                        hint: 'PIN Code',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        prefixIcon: Icons.lock,
                        isRequred: false,
                        controller: pin,
                        label: 'PIN Code',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ButtonWidget(
                        label: 'Create',
                        onPressed: () {
                          addCashier(name.text, pin.text);
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
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
                  text: 'Cashiers',
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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: Icon(
                              Icons.account_circle_outlined,
                              color: blue,
                              size: 50,
                            ),
                            title: TextWidget(
                              text: data.docs[index]['name'],
                              fontSize: 18,
                              fontFamily: 'Bold',
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('Cashiers')
                                    .doc(data.docs[index].id)
                                    .delete();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 28,
                              ),
                            ));
                      },
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
