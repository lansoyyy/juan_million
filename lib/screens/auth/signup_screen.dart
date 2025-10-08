import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/signup_screen2.dart';
import 'package:juan_million/screens/pages/terms_conditions_page.dart';
import 'package:juan_million/services/add_business.dart';
import 'package:juan_million/services/add_referal.dart';
import 'package:juan_million/utlis/app_common.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();

  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  final ref = TextEditingController();

  bool _value = true;

  void _handleNext() async {
    if (ref.text == '') {
      if (email.text != '' || password.text != '' || name.text != '') {
        if (password.text == confirmpassword.text) {
          register(context);
        } else {
          showToast('Password do not match!');
        }
      } else {
        showToast('All fields are required!');
      }
    } else {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Referals')
          .doc(ref.text)
          .get();

      if (doc.exists) {
        if (email.text != '' || password.text != '' || name.text != '') {
          if (password.text == confirmpassword.text) {
            await FirebaseFirestore.instance
                .collection(doc['type'])
                .doc(doc['uid'])
                .update({'pts': FieldValue.increment(20)});
            register(context);
          } else {
            showToast('Password do not match!');
          }
        } else {
          showToast('All fields are required!');
        }
      } else {
        showToast('Cannot proceed! Referral Code does not exist!');
      }
    }
  }

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
                          text: 'Grow Your Business with Juan 4 All',
                          fontSize: 36,
                          fontFamily: 'Bold',
                          color: Colors.white,
                          align: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextWidget(
                          text:
                              'Join thousands of businesses using our platform to accept payments and manage transactions',
                          fontSize: 18,
                          fontFamily: 'Regular',
                          color: Colors.white.withOpacity(0.9),
                          align: TextAlign.center,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                        // Benefits
                        _buildBenefitItem(
                            Icons.storefront, 'Business Dashboard'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(Icons.analytics, 'Sales Analytics'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(Icons.qr_code_scanner, 'QR Payments'),
                        const SizedBox(height: 15),
                        _buildBenefitItem(Icons.loyalty, 'Loyalty Programs'),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(60),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
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
                      const SizedBox(height: 40),
                      TextWidget(
                        text: 'Business Registration',
                        fontSize: 32,
                        fontFamily: 'Bold',
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      TextWidget(
                        text: 'Step 1 of 3: Basic Information',
                        fontSize: 16,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 40),
                      // Business Name
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Business Name',
                        borderColor: Colors.grey.shade300,
                        radius: 12,
                        width: double.infinity,
                        isRequred: false,
                        prefixIcon: Icons.business,
                        controller: name,
                        label: 'Business Name',
                      ),
                      const SizedBox(height: 20),
                      // Business Email
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Business Email',
                        borderColor: Colors.grey.shade300,
                        radius: 12,
                        width: double.infinity,
                        isRequred: false,
                        controller: email,
                        prefixIcon: Icons.email_outlined,
                        label: 'Business Email',
                      ),
                      const SizedBox(height: 20),
                      // Password
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
                      // Confirm Password
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
                      // Referral Code
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
                      const SizedBox(height: 20),
                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            activeColor: primary,
                            value: _value,
                            onChanged: (value) {
                              setState(() {
                                _value = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                TextWidget(
                                    text: 'I agree with ',
                                    fontSize: 14,
                                    color: Colors.grey.shade700),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsAndConditionsPage()));
                                    },
                                    child: TextWidget(
                                        text: 'Terms and Conditions',
                                        fontSize: 14,
                                        fontFamily: 'Bold',
                                        color: primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Next button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ButtonWidget(
                          width: double.infinity,
                          label: 'Next',
                          onPressed: _value ? _handleNext : () {},
                          color: primary,
                          radius: 12,
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
                              Navigator.pop(context);
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
                    ],
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
                      text: 'Business Registration',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Step 1 of 3: Basic Information',
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
                    // Form fields with modern styling
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Business Name',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      prefixIcon: Icons.business,
                      controller: name,
                      label: 'Business Name',
                    ),
                    const SizedBox(height: 20),
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Business Email',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      controller: email,
                      prefixIcon: Icons.email_outlined,
                      label: 'Business Email',
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
                    const SizedBox(height: 20),
                    // Terms and conditions checkbox
                    Row(
                      children: [
                        Checkbox(
                          activeColor: primary,
                          value: _value,
                          onChanged: (value) {
                            setState(() {
                              _value = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              TextWidget(
                                  text: 'I agree with ',
                                  fontSize: 14,
                                  color: Colors.grey.shade700),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsAndConditionsPage()));
                                },
                                child: TextWidget(
                                    text: 'Terms and Conditions',
                                    fontSize: 14,
                                    fontFamily: 'Bold',
                                    color: primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Next button with gradient
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _value
                            ? LinearGradient(
                                colors: [primary, secondary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade300
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _value
                            ? [
                                BoxShadow(
                                  color: primary.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _value
                              ? () async {
                                  if (ref.text == '') {
                                    if (email.text != '' ||
                                        password.text != '' ||
                                        name.text != '') {
                                      if (password.text == confirmpassword.text) {
                                        register(context);
                                      } else {
                                        showToast('Password do not match!');
                                      }
                                    } else {
                                      showToast('All fields are required!');
                                    }
                                  } else {
                                    DocumentSnapshot doc =
                                        await FirebaseFirestore.instance
                                            .collection('Referals')
                                            .doc(ref.text)
                                            .get();

                                    if (doc.exists) {
                                      if (email.text != '' ||
                                          password.text != '' ||
                                          name.text != '') {
                                        if (password.text ==
                                            confirmpassword.text) {
                                          await FirebaseFirestore.instance
                                              .collection(doc['type'])
                                              .doc(doc['uid'])
                                              .update({
                                            'pts': FieldValue.increment(20)
                                          });
                                          register(context);
                                        } else {
                                          showToast('Password do not match!');
                                        }
                                      } else {
                                        showToast('All fields are required!');
                                      }
                                    } else {
                                      showToast(
                                          'Cannot proceed! Referral Code does not exist!');
                                    }
                                  }
                                }
                              : null,
                          child: Center(
                            child: TextWidget(
                              text: 'Next',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
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
        final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text, password: password.text);

        // addUser(name.text, email.text);
        addBusiness(name.text, email.text, '', '', '', '', '', key);
        addReferal(key, 'Business');

        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text, password: password.text);

        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        showToast(
            "Registered Successfully! Verification was sent to your email");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => SignupScreen2(
                  id: user.user!.uid,
                )));
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
}
