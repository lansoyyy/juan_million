import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/pages/business/profile_page.dart';
import 'package:juan_million/screens/pages/customer/myqr_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CustomerSettingsPage extends StatefulWidget {
  const CustomerSettingsPage({super.key});

  @override
  State<CustomerSettingsPage> createState() => _CustomerSettingsPageState();
}

class _CustomerSettingsPageState extends State<CustomerSettingsPage> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();
  final number = TextEditingController();

  final password = TextEditingController();

  final pts = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
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
            dynamic data = snapshot.data;

            fname.text = data['name'].toString().split(' ')[0];
            lname.text = data['name'].toString().split(' ')[1];
            number.text = data['phone'];
            email.text = data['email'];
            password.text = '*******';
            return SafeArea(
              child: SingleChildScrollView(
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
                          text: 'Profile',
                          fontSize: 18,
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                maxRadius: 40,
                                minRadius: 40,
                                backgroundImage: NetworkImage(data['pic']),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                      text: data['name'],
                                      fontSize: 18,
                                      fontFamily: 'Bold',
                                      color: Colors.white),
                                  TextWidget(
                                      text: data['email'],
                                      fontSize: 11,
                                      fontFamily: 'Medium',
                                      color: Colors.white54),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'First Name',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        prefixIcon: Icons.person_3_outlined,
                        controller: fname,
                        label: 'Business Name',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Last Name',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        prefixIcon: Icons.person_3_outlined,
                        controller: lname,
                        label: 'Business Name',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextFieldWidget(
                        inputType: TextInputType.number,
                        fontStyle: FontStyle.normal,
                        hint: 'Contact Number',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        controller: number,
                        prefixIcon: Icons.phone,
                        label: 'Business Email',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextFieldWidget(
                        isEnabled: false,
                        fontStyle: FontStyle.normal,
                        hint: 'Email',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        controller: email,
                        prefixIcon: Icons.email_outlined,
                        label: 'Business Email',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: TextFieldWidget(
                        isEnabled: false,
                        showEye: true,
                        isObscure: true,
                        prefixIcon: Icons.lock_open_outlined,
                        fontStyle: FontStyle.normal,
                        hint: 'Password',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        controller: password,
                        label: 'Password',
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ButtonWidget(
                        width: 350,
                        label: 'Update Profile',
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(data.id)
                              .update({
                            'name': '${fname.text} ${lname.text}',
                            'phone': number.text,
                          });
                          showToast('Profile updated!');
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'More',
                            color: blue,
                            fontSize: 14,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyQRPage()));
                              },
                              tileColor: Colors.white,
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: blue.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.qr_code,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              title: TextWidget(
                                text: 'My QR Code',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Logout Confirmation',
                                            style: TextStyle(
                                                fontFamily: 'QBold',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to Logout?',
                                            style: TextStyle(
                                                fontFamily: 'QRegular'),
                                          ),
                                          actions: <Widget>[
                                            MaterialButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                await FirebaseAuth.instance
                                                    .signOut();
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LandingScreen()));
                                              },
                                              child: const Text(
                                                'Continue',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ));
                              },
                              tileColor: Colors.white,
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: blue.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              title: TextWidget(
                                text: 'Logout',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
