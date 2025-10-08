import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/services/add_referal.dart';
import 'package:juan_million/services/add_user.dart';
import 'package:juan_million/utlis/app_common.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/address_widget.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:path/path.dart' as path;

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();

  final ref = TextEditingController();

  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  final nickname = TextEditingController();

  final number = TextEditingController();

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

  Region? region;
  Province? province;
  Municipality? municipality;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  secondary,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/newbackground.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Juan4All 2.png',
                          height: 180,
                        ),
                        const SizedBox(height: 40),
                        TextWidget(
                          text: 'Join Juan 4 All Today!',
                          fontSize: 36,
                          fontFamily: 'Bold',
                          color: Colors.white,
                          align: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextWidget(
                          text:
                              'Create your account and start managing your payments with ease',
                          fontSize: 18,
                          fontFamily: 'Regular',
                          color: Colors.white.withOpacity(0.9),
                          align: TextAlign.center,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                        // Benefits
                        _buildBenefitItem(Icons.account_balance_wallet,
                            'Free Digital Wallet'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(Icons.qr_code, 'QR Code Payments'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(Icons.receipt, 'Easy Bill Payments'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(
                            Icons.card_giftcard, 'Referral Rewards'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Signup Form
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back,
                              color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextWidget(
                      text: 'Create Account',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: 'Sign up as a customer to get started',
                      fontSize: 16,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 30),
                    // Profile Picture
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            maxRadius: 60,
                            minRadius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: imageURL.isNotEmpty
                                ? NetworkImage(imageURL)
                                : null,
                            child: imageURL.isEmpty
                                ? Icon(Icons.person,
                                    size: 60, color: Colors.grey.shade400)
                                : null,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              uploadPicture('gallery');
                            },
                            icon: Icon(Icons.upload, color: primary, size: 18),
                            label: TextWidget(
                              text: 'Upload Picture',
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Name fields in row
                    Row(
                      children: [
                        Expanded(
                          child: TextFieldWidget(
                            fontStyle: FontStyle.normal,
                            hint: 'Firstname',
                            borderColor: Colors.grey.shade300,
                            radius: 12,
                            width: double.infinity,
                            isRequred: false,
                            prefixIcon: Icons.person_outline,
                            controller: fname,
                            label: 'Firstname',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFieldWidget(
                            fontStyle: FontStyle.normal,
                            hint: 'Lastname',
                            borderColor: Colors.grey.shade300,
                            radius: 12,
                            width: double.infinity,
                            isRequred: false,
                            prefixIcon: Icons.person_outline,
                            controller: lname,
                            label: 'Lastname',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Nickname',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.badge_outlined,
                      controller: nickname,
                      label: 'Nickname',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Mobile Number',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: true,
                      inputType: TextInputType.number,
                      maxLength: 11,
                      height: 70,
                      prefixIcon: Icons.phone,
                      controller: number,
                      label: 'Mobile Number',
                    ),
                    const SizedBox(height: 20),
                    // Address dropdowns
                    CustomRegionDropdownView(
                        onChanged: (Region? value) {
                          setState(() {
                            if (region != value) {
                              province = null;
                              municipality = null;
                            }
                            region = value;
                          });
                        },
                        value: region),
                    const SizedBox(height: 20),
                    CustomProvinceDropdownView(
                      provinces: region?.provinces ?? [],
                      onChanged: (Province? value) {
                        setState(() {
                          if (province != value) {
                            municipality = null;
                          }
                          province = value;
                        });
                      },
                      value: province,
                    ),
                    const SizedBox(height: 20),
                    CustomMunicipalityDropdownView(
                      municipalities: province?.municipalities ?? [],
                      onChanged: (value) {
                        setState(() {
                          municipality = value;
                        });
                      },
                      value: municipality,
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Email',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      controller: email,
                      prefixIcon: Icons.email_outlined,
                      label: 'Email',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      showEye: true,
                      isObscure: true,
                      prefixIcon: Icons.lock_outline,
                      fontStyle: FontStyle.normal,
                      hint: 'Password',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      controller: password,
                      label: 'Password',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      showEye: true,
                      isObscure: true,
                      prefixIcon: Icons.lock_outline,
                      fontStyle: FontStyle.normal,
                      hint: 'Confirm Password',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      controller: confirmpassword,
                      label: 'Confirm Password',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Referral Code (Optional)',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.card_giftcard,
                      controller: ref,
                      label: 'Referral Code',
                    ),
                    const SizedBox(height: 30),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ButtonWidget(
                        width: double.infinity,
                        label: 'Create Account',
                        onPressed: () async {
                          if (ref.text == '') {
                            if (password.text == confirmpassword.text) {
                              if (fname.text != '' ||
                                  lname.text != '' ||
                                  nickname.text != '' ||
                                  email.text != '' ||
                                  password.text != '') {
                                register(context);
                              } else {
                                showToast('All fields are required!');
                              }
                            } else {
                              showToast('Password do not match!');
                            }
                          } else {
                            DocumentSnapshot doc = await FirebaseFirestore
                                .instance
                                .collection('Referals')
                                .doc(ref.text)
                                .get();

                            if (doc.exists) {
                              if (password.text == confirmpassword.text) {
                                if (fname.text != '' ||
                                    lname.text != '' ||
                                    nickname.text != '' ||
                                    email.text != '' ||
                                    password.text != '') {
                                  await FirebaseFirestore.instance
                                      .collection(doc['type'])
                                      .doc(doc['uid'])
                                      .update(
                                          {'pts': FieldValue.increment(20)});
                                  register(context);
                                } else {
                                  showToast('All fields are required!');
                                }
                              } else {
                                showToast('Password do not match!');
                              }
                            } else {
                              showToast(
                                  'Cannot proceed! Referral Code does not exist!');
                            }
                          }
                        },
                        color: primary,
                        radius: 12,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextWidget(
                            text: 'or',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Google signup
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          googleLogin();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/googlelogo.png',
                                width: 24,
                              ),
                              const SizedBox(width: 15),
                              TextWidget(
                                text: 'Continue with Google',
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontFamily: 'Medium',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          text: "Already have an account?",
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    LoginScreen(inCustomer: true)));
                          },
                          child: TextWidget(
                            text: 'Sign In',
                            fontSize: 14,
                            fontFamily: 'Bold',
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 15),
        TextWidget(
          text: text,
          fontSize: 16,
          fontFamily: 'Medium',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo and header section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  children: [
                    // Logo with shadow
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/Juan4All 2.png',
                        height: 70,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Title
                    TextWidget(
                      text: 'Create Account',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Sign up as a customer to get started',
                      fontSize: 15,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile picture upload
                    Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: imageURL.isNotEmpty
                                  ? NetworkImage(imageURL)
                                  : null,
                              child: imageURL.isEmpty
                                  ? Icon(Icons.person,
                                      size: 50, color: Colors.grey.shade400)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  uploadPicture('gallery');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, secondary],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextWidget(
                          text: 'Upload Profile Picture',
                          fontSize: 13,
                          fontFamily: 'Medium',
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Form fields with modern styling
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Firstname',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.person_outline,
                      controller: fname,
                      label: 'Firstname',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Lastname',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.person_outline,
                      controller: lname,
                      label: 'Lastname',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Nickname',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.badge_outlined,
                      controller: nickname,
                      label: 'Nickname',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Mobile Number',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: true,
                      inputType: TextInputType.number,
                      maxLength: 11,
                      height: 70,
                      prefixIcon: Icons.phone,
                      controller: number,
                      label: 'Mobile Number',
                    ),
                    const SizedBox(height: 20),
                    CustomRegionDropdownView(
                        onChanged: (Region? value) {
                          setState(() {
                            if (region != value) {
                              province = null;
                              municipality = null;
                            }
                            region = value;
                          });
                        },
                        value: region),
                    const SizedBox(height: 20),
                    CustomProvinceDropdownView(
                      provinces: region?.provinces ?? [],
                      onChanged: (Province? value) {
                        setState(() {
                          if (province != value) {
                            municipality = null;
                          }
                          province = value;
                        });
                      },
                      value: province,
                    ),
                    const SizedBox(height: 20),
                    CustomMunicipalityDropdownView(
                      municipalities: province?.municipalities ?? [],
                      onChanged: (value) {
                        setState(() {
                          municipality = value;
                        });
                      },
                      value: municipality,
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Email',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      controller: email,
                      prefixIcon: Icons.email_outlined,
                      label: 'Email',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      showEye: true,
                      isObscure: true,
                      prefixIcon: Icons.lock_outline,
                      fontStyle: FontStyle.normal,
                      hint: 'Password',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      controller: password,
                      label: 'Password',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      showEye: true,
                      isObscure: true,
                      prefixIcon: Icons.lock_outline,
                      fontStyle: FontStyle.normal,
                      hint: 'Confirm Password',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      controller: confirmpassword,
                      label: 'Confirm Password',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Referral Code (Optional)',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.card_giftcard,
                      controller: ref,
                      label: 'Referral Code',
                    ),
                    const SizedBox(height: 30),
                    // Create account button with gradient
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            if (ref.text == '') {
                              if (password.text == confirmpassword.text) {
                                if (fname.text != '' ||
                                    lname.text != '' ||
                                    nickname.text != '' ||
                                    email.text != '' ||
                                    password.text != '') {
                                  register(context);
                                } else {
                                  showToast('All fields are required!');
                                }
                              } else {
                                showToast('Password do not match!');
                              }
                            } else {
                              DocumentSnapshot doc = await FirebaseFirestore
                                  .instance
                                  .collection('Referals')
                                  .doc(ref.text)
                                  .get();

                              if (doc.exists) {
                                if (password.text == confirmpassword.text) {
                                  if (fname.text != '' ||
                                      lname.text != '' ||
                                      nickname.text != '' ||
                                      email.text != '' ||
                                      password.text != '') {
                                    await FirebaseFirestore.instance
                                        .collection(doc['type'])
                                        .doc(doc['uid'])
                                        .update(
                                            {'pts': FieldValue.increment(20)});
                                    register(context);
                                  } else {
                                    showToast('All fields are required!');
                                  }
                                } else {
                                  showToast('Password do not match!');
                                }
                              } else {
                                showToast(
                                    'Cannot proceed! Referral Code does not exist!');
                              }
                            }
                          },
                          child: Center(
                            child: TextWidget(
                              text: 'Create Account',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Divider with gradient
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextWidget(
                            text: 'OR',
                            fontSize: 12,
                            fontFamily: 'Bold',
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Google sign up button
                    GestureDetector(
                      onTap: () {
                        googleLogin();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/googlelogo.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 12),
                            TextWidget(
                              text: 'Continue with Google',
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Sign in link
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Already have an account?",
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontFamily: 'Regular',
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.1),
                              secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextWidget(
                          text: 'Sign In',
                          fontSize: 15,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  register(context) async {
    String key = generateUniqueKey(6);
    if (hasSpecialCharacter(password.text)) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text, password: password.text);

        addUser(
            '${fname.text} ${lname.text}',
            email.text,
            nickname.text,
            imageURL,
            '${municipality!.name}, ${province!.name}',
            number.text,
            key);

        addReferal(key, 'Users');

        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text, password: password.text);

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        showToast(
            "Registered Successfully! Verification was sent to your email");

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoginScreen(
                    inCustomer: true,
                  )),
          (route) {
            return false;
          },
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showToast('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          showToast('The account already exists for that email.');
        } else if (e.code == 'invalid-email') {
          showToast('The email address is not valid.');
        } else {
          showToast(e.toString());
        }
      } on Exception catch (e) {
        showToast("An error occurred: $e");
      }
    } else {
      showToast('Password should have atleast special character!');
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  bool userExist = false;

  googleLogin() async {
    try {
      final googleSignInAccount = await googleSignIn.signIn();

      print(googleSignInAccount!.email);

      FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: googleSignInAccount.email)
          .get()
          .then(
        (value) {
          print(value);
        },
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: googleSignInAccount.email)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        for (var doc in querySnapshot.docs) {
          if (doc['email'] == googleSignInAccount.email) {
            setState(() {
              userExist = true;
            });
          }
        }
      }).whenComplete(
        () async {
          String key = generateUniqueKey(6);
          if (userExist) {
            Navigator.pop(context);

            showToast('Your google account is already used! Try logging in.');
          } else {
            // If the user doesn't exist, create a new user with Google credentials
            try {
              // Authenticate the GoogleSignInAccount and get the credentials
              final googleSignInAuth = await googleSignInAccount.authentication;
              final credential = GoogleAuthProvider.credential(
                accessToken: googleSignInAuth.accessToken,
                idToken: googleSignInAuth.idToken,
              );

              // Sign in to Firebase with the obtained credentials
              UserCredential userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);

              // Add the user to your Firestore or Realtime Database if needed
              addUser(
                  googleSignInAccount.displayName,
                  googleSignInAccount.email,
                  googleSignInAccount.displayName,
                  googleSignInAccount.photoUrl,
                  '',
                  '',
                  key);

              addReferal(key, 'Users');
            } catch (e) {
              print('Error: $e');
              // Handle the error accordingly
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const CustomerHomeScreen()),
              (route) {
                return false;
              },
            );
          }

// Navigate to the CustomerHomeScreen and remove all previous routes
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
