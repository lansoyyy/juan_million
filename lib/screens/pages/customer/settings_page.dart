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
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
      appBar: AppBar(
        title: TextWidget(
          text: 'Profile Settings',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add save functionality
            },
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        ],
      ),
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

            String isNumber = data['email'].toString().split('@')[0];

            fname.text = data['name'].toString().split(' ')[0];
            lname.text = data['name'].toString().split(' ')[1];
            number.text = isPhoneNumber(isNumber) ? isNumber : data['number'];
            email.text = isPhoneNumber(isNumber) ? '' : data['email'];
            password.text = '*******';

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced profile section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 30, left: 20, right: 20),
                        child: Column(
                          children: [
                            // Profile picture with edit button
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    uploadPicture('gallery');
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          NetworkImage(data['pic']),
                                      onBackgroundImageError:
                                          (exception, stackTrace) {
                                        // Handle error
                                      },
                                      child: data['pic'] == null ||
                                              data['pic'].toString().isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // User info
                            TextWidget(
                              text: data['name'],
                              fontSize: 22,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            TextWidget(
                              text: data['email'],
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Form section with improved styling
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title
                          TextWidget(
                            text: 'Personal Information',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 20),

                          // First name field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextFieldWidget(
                              fontStyle: FontStyle.normal,
                              hint: 'First Name',
                              borderColor: Colors.transparent,
                              radius: 15,
                              width: double.infinity,
                              isRequred: false,
                              prefixIcon: Icons.person_3_outlined,
                              controller: fname,
                              label: 'First Name',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Last name field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextFieldWidget(
                              fontStyle: FontStyle.normal,
                              hint: 'Last Name',
                              borderColor: Colors.transparent,
                              radius: 15,
                              width: double.infinity,
                              isRequred: false,
                              prefixIcon: Icons.person_3_outlined,
                              controller: lname,
                              label: 'Last Name',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Contact number field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextFieldWidget(
                              inputType: TextInputType.number,
                              fontStyle: FontStyle.normal,
                              hint: 'Contact Number',
                              borderColor: Colors.transparent,
                              radius: 15,
                              width: double.infinity,
                              isRequred: false,
                              controller: number,
                              prefixIcon: Icons.phone,
                              label: 'Contact Number',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextFieldWidget(
                              isEnabled: false,
                              fontStyle: FontStyle.normal,
                              hint: 'Email',
                              borderColor: Colors.transparent,
                              radius: 15,
                              width: double.infinity,
                              isRequred: false,
                              controller: email,
                              prefixIcon: Icons.email_outlined,
                              label: 'Email',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextFieldWidget(
                              isEnabled: false,
                              showEye: true,
                              isObscure: true,
                              prefixIcon: Icons.lock_open_outlined,
                              fontStyle: FontStyle.normal,
                              hint: 'Password',
                              borderColor: Colors.transparent,
                              radius: 15,
                              width: double.infinity,
                              isRequred: false,
                              controller: password,
                              label: 'Password',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Referral code field
                          StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Referals')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
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
                                dynamic referralData = snapshot.data;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: TextFieldWidget(
                                    isEnabled: false,
                                    fontStyle: FontStyle.normal,
                                    hint: 'Referral Code',
                                    borderColor: Colors.transparent,
                                    radius: 15,
                                    width: double.infinity,
                                    isRequred: false,
                                    prefixIcon: Icons.card_giftcard_sharp,
                                    controller: TextEditingController(
                                      text:
                                          '${referralData['ref']} (Referral Code)',
                                    ),
                                    label: 'Referral Code',
                                  ),
                                );
                              }),
                          const SizedBox(height: 30),

                          // Update button
                          ButtonWidget(
                            width: double.infinity,
                            label: 'Update Profile',
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(data.id)
                                  .update({
                                'name': '${fname.text} ${lname.text}',
                                'number': number.text,
                              });
                              showToast('Profile updated!');
                            },
                          ),
                          const SizedBox(height: 30),

                          // More options section
                          TextWidget(
                            text: 'More Options',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 15),

                          // My QR Code option
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyQRPage()));
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Colors.blue,
                                ),
                              ),
                              title: TextWidget(
                                text: 'My QR Code',
                                fontSize: 16,
                                color: Colors.black87,
                                fontFamily: 'Medium',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Logout option
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          title: const Text(
                                            'Logout Confirmation',
                                            style: TextStyle(
                                                fontFamily: 'Bold',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to logout?',
                                            style: TextStyle(
                                                fontFamily: 'Regular'),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    fontFamily: 'Medium',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            TextButton(
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
                                                'Logout',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily: 'Medium',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ));
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                              ),
                              title: TextWidget(
                                text: 'Logout',
                                fontSize: 16,
                                color: Colors.black87,
                                fontFamily: 'Medium',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName')
            .getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'pic': imageURL,
        });

        setState(() {});

        Navigator.of(context).pop();
        showToast('Image uploaded!');
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  bool isPhoneNumber(String input) {
    // Define a regex pattern that matches Philippine phone number formats
    RegExp phoneRegex = RegExp(
      r'^(09|\+639)\d{9}$',
      caseSensitive: false,
      multiLine: false,
    );

    // Use RegExp's hasMatch method to check if the input matches the pattern
    return phoneRegex.hasMatch(input);
  }
}
