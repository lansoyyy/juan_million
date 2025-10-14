import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:juan_million/screens/auth/customer_signup_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/services/add_user.dart';
import 'package:juan_million/utlis/app_common.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  bool inCustomer;

  LoginScreen({super.key, required this.inCustomer});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();

  final password = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                          text: widget.inCustomer
                              ? 'Welcome Back, ka-Juan!'
                              : 'Welcome Back, ka-Negosyo!',
                          fontSize: 36,
                          fontFamily: 'Bold',
                          color: Colors.white,
                          align: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextWidget(
                          text: widget.inCustomer
                              ? 'Manage your payments and transactions with ease'
                              : 'Grow your business with our powerful payment solutions',
                          fontSize: 18,
                          fontFamily: 'Regular',
                          color: Colors.white.withOpacity(0.9),
                          align: TextAlign.center,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                        // Features
                        _buildFeatureItem(
                            Icons.security, 'Bank-level Security'),
                        const SizedBox(height: 15),
                        _buildFeatureItem(
                            Icons.flash_on, 'Instant Transactions'),
                        const SizedBox(height: 15),
                        _buildFeatureItem(Icons.support_agent, '24/7 Support'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Login Form
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
                        text: 'Sign In',
                        fontSize: 32,
                        fontFamily: 'Bold',
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      TextWidget(
                        text: widget.inCustomer
                            ? 'Access your customer account'
                            : 'Access your business account',
                        fontSize: 16,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 40),
                      // Email field
                      TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Enter your email',
                        borderColor: Colors.grey.shade300,
                        radius: 12,
                        width: double.infinity,
                        prefixIcon: Icons.email_outlined,
                        isRequred: false,
                        controller: username,
                        label: 'Email Address',
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      TextFieldWidget(
                        showEye: true,
                        isObscure: true,
                        fontStyle: FontStyle.normal,
                        hint: 'Enter your password',
                        borderColor: Colors.grey.shade300,
                        radius: 12,
                        width: double.infinity,
                        prefixIcon: Icons.lock_outline,
                        isRequred: false,
                        controller: password,
                        label: 'Password',
                      ),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog(context);
                          },
                          child: TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 14,
                            color: primary,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Login button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ButtonWidget(
                          width: double.infinity,
                          label: 'Sign In',
                          onPressed: () async {
                            var document =
                                FirebaseFirestore.instance.doc('App/versions');
                            var snapshot = await document.get();

                            if (snapshot.data()!['version'] == version) {
                              login(context);
                            } else {
                              showToast(
                                  'Cannot Proceed! Your app version is outdated!',
                                  context: context);
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
                      // Google login
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
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
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: "Don't have an account?",
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          TextButton(
                            onPressed: () {
                              if (widget.inCustomer) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerSignupScreen()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen()));
                              }
                            },
                            child: TextWidget(
                              text: 'Sign Up',
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

  Widget _buildFeatureItem(IconData icon, String text) {
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
              // Logo and welcome section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    // Logo with shadow
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Welcome text
                    TextWidget(
                      text:
                          widget.inCustomer ? 'Welcome Back!' : 'Welcome Back!',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: widget.inCustomer
                          ? 'Sign in to your customer account'
                          : 'Sign in to your business account',
                      fontSize: 16,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                      align: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Form container with modern card design
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field with icon container
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                color: primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextWidget(
                              text: 'Email Address',
                              fontSize: 16,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFieldWidget(
                          fontStyle: FontStyle.normal,
                          hint: 'Enter your email',
                          borderColor: Colors.grey.shade200,
                          radius: 15,
                          width: double.infinity,
                          prefixIcon: null,
                          isRequred: false,
                          controller: username,
                          label: '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Password field with icon container
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextWidget(
                              text: 'Password',
                              fontSize: 16,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFieldWidget(
                          showEye: true,
                          isObscure: true,
                          fontStyle: FontStyle.normal,
                          hint: 'Enter your password',
                          borderColor: Colors.grey.shade200,
                          radius: 15,
                          width: double.infinity,
                          prefixIcon: null,
                          isRequred: false,
                          controller: password,
                          label: '',
                        ),
                      ],
                    ),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showForgotPasswordDialog(context);
                        },
                        child: TextWidget(
                          text: 'Forgot Password?',
                          fontSize: 14,
                          color: primary,
                          fontFamily: 'Bold',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Sign in button with gradient
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
                            var document =
                                FirebaseFirestore.instance.doc('App/versions');
                            var snapshot = await document.get();

                            if (snapshot.data()!['version'] == version) {
                              login(context);
                            } else {
                              showToast(
                                  'Cannot Proceed! Your app version is outdated!',
                                  context: context);
                            }
                          },
                          child: Center(
                            child: TextWidget(
                              text: 'Sign In',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Divider with text
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

                    // Google sign in button
                    GestureDetector(
                      onTap: () async {
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

              // Sign up section with better design
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Don't have an account?",
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontFamily: 'Regular',
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (widget.inCustomer) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerSignupScreen()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                        }
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
                          text: 'Sign Up',
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

  login(context) async {
    if (isPhoneNumber(username.text)) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('number', isEqualTo: username.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        try {
          final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: querySnapshot.docs.first['email'],
              password: password.text);

          if (widget.inCustomer) {
            if (user.user!.emailVerified) {
              // Check if user data exists in Firestore
              var userDoc = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.user!.uid)
                  .get();

              if (!userDoc.exists) {
                // If user data doesn't exist, create it
                await addUser(
                    querySnapshot.docs.first['name'] ?? '',
                    querySnapshot.docs.first['email'],
                    querySnapshot.docs.first['nickname'] ?? '',
                    querySnapshot.docs.first['pic'] ?? '',
                    querySnapshot.docs.first['address'] ?? '',
                    querySnapshot.docs.first['number'] ?? '',
                    querySnapshot.docs.first['ref'] ?? '');
              }

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const CustomerHomeScreen()),
                (route) {
                  return false;
                },
              );
            } else {
              showToast('Cannot proceed! Email not verified', context: context);
            }
          } else {
            if (user.user!.emailVerified) {
              // Check if business data exists in Firestore
              var businessDoc = await FirebaseFirestore.instance
                  .collection('Business')
                  .doc(user.user!.uid)
                  .get();

              if (!businessDoc.exists) {
                // If business data doesn't exist, we need to get the business data using email
                var businessQuerySnapshot = await FirebaseFirestore.instance
                    .collection('Business')
                    .where('email',
                        isEqualTo: querySnapshot.docs.first['email'])
                    .get();

                if (businessQuerySnapshot.docs.isNotEmpty) {
                  // Create the business document with the existing data
                  await FirebaseFirestore.instance
                      .collection('Business')
                      .doc(user.user!.uid)
                      .set(businessQuerySnapshot.docs.first.data());
                }
              }

              var document =
                  FirebaseFirestore.instance.doc('Business/${user.user!.uid}');
              var snapshot = await document.get();
              if (snapshot.data()!['verified'] == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const BusinessHomeScreen()),
                  (route) {
                    return false;
                  },
                );
              } else {
                showToast('Request grant access!', context: context);
              }
            } else {
              showToast('Cannot proceed! Email not verified', context: context);
            }
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            showToast("No user found with that email.", context: context);
          } else if (e.code == 'wrong-password') {
            showToast("Wrong password provided for that user.",
                context: context);
          } else if (e.code == 'invalid-email') {
            showToast("Invalid email provided.", context: context);
          } else if (e.code == 'user-disabled') {
            showToast("User account has been disabled.", context: context);
          } else {
            showToast("An error occurred: ${e.message}", context: context);
          }
        } on Exception catch (e) {
          showToast("An error occurred: $e", context: context);
        }
      } else {
        showToast('Cannot proceed! Mobile Number not found', context: context);
      }
    } else {
      try {
        final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: username.text, password: password.text);

        if (widget.inCustomer) {
          if (user.user!.emailVerified) {
            // Check if user data exists in Firestore
            var userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.user!.uid)
                .get();

            if (!userDoc.exists) {
              // If user data doesn't exist, we need to get the user data from the Users collection using email
              var querySnapshot = await FirebaseFirestore.instance
                  .collection('Users')
                  .where('email', isEqualTo: username.text)
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                // Create the user document with the existing data
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.user!.uid)
                    .set(querySnapshot.docs.first.data());
              }
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const CustomerHomeScreen()),
              (route) {
                return false;
              },
            );
          } else {
            showToast('Cannot proceed! Email not verified', context: context);
          }
        } else {
          if (user.user!.emailVerified) {
            // Check if business data exists in Firestore
            var businessDoc = await FirebaseFirestore.instance
                .collection('Business')
                .doc(user.user!.uid)
                .get();

            if (!businessDoc.exists) {
              // If business data doesn't exist, we need to get the business data using email
              var businessQuerySnapshot = await FirebaseFirestore.instance
                  .collection('Business')
                  .where('email', isEqualTo: username.text)
                  .get();

              if (businessQuerySnapshot.docs.isNotEmpty) {
                // Create the business document with the existing data
                await FirebaseFirestore.instance
                    .collection('Business')
                    .doc(user.user!.uid)
                    .set(businessQuerySnapshot.docs.first.data());
              }
            }

            var document =
                FirebaseFirestore.instance.doc('Business/${user.user!.uid}');
            var snapshot = await document.get();
            if (snapshot.data()!['verified'] == true) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const BusinessHomeScreen()),
                (route) {
                  return false;
                },
              );
            } else {
              showToast('Request grant access!', context: context);
            }
          } else {
            showToast('Cannot proceed! Email not verified', context: context);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showToast("No user found with that email.", context: context);
        } else if (e.code == 'wrong-password') {
          showToast("Wrong password provided for that user.", context: context);
        } else if (e.code == 'invalid-email') {
          showToast("Invalid email provided.", context: context);
        } else if (e.code == 'user-disabled') {
          showToast("User account has been disabled.", context: context);
        } else {
          showToast("An error occurred: ${e.message}", context: context);
        }
      } on Exception catch (e) {
        showToast("An error occurred: $e", context: context);
      }
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  bool userExist = false;

  googleLogin() async {
    try {
      final googleSignInAccount = await googleSignIn.signIn();

      print(googleSignInAccount!.email);

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
          if (userExist) {
            print('1');

            // Authenticate the GoogleSignInAccount and get the credentials
            final googleSignInAuth = await googleSignInAccount.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleSignInAuth.accessToken,
              idToken: googleSignInAuth.idToken,
            );

            // Sign in to Firebase with the obtained credentials
            await FirebaseAuth.instance.signInWithCredential(credential);
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
                  generateUniqueKey(6));
            } catch (e) {
              print('Error: $e');
              // Handle the error accordingly
            }
          }

// Check if user data exists in Firestore
          var userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

          if (!userDoc.exists) {
            // If user data doesn't exist, create it
            await addUser(
                googleSignInAccount.displayName ?? '',
                googleSignInAccount.email,
                googleSignInAccount.displayName ?? '',
                googleSignInAccount.photoUrl,
                '',
                '',
                generateUniqueKey(6));
          }

// Navigate to the CustomerHomeScreen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
            (route) {
              return false;
            },
          );
        },
      );
    } catch (e) {
      print('123');
      print(e);
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

  void _showForgotPasswordDialog(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: ((context) {
        final formKey = GlobalKey<FormState>();
        final TextEditingController emailController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Forgot Password',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextWidget(
                        text:
                            'Enter your email address to receive a password reset link.',
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        maxLines: 2,
                        align: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: TextFieldWidget(
                        hint: 'Email',
                        textCapitalization: TextCapitalization.none,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: (() {
                            Navigator.pop(context);
                          }),
                          child: TextWidget(
                            text: 'Cancel',
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontFamily: 'Medium',
                          ),
                        ),
                        isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: (() async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      if (isPhoneNumber(emailController.text)) {
                                        var querySnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('Users')
                                                .where('number',
                                                    isEqualTo:
                                                        emailController.text)
                                                .get();

                                        if (querySnapshot.docs.isNotEmpty) {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                                  email: querySnapshot
                                                      .docs.first['email']);

                                          Navigator.pop(context);
                                          _showPasswordResetSuccessDialog(
                                              context,
                                              querySnapshot
                                                  .docs.first['email']);
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          showToast('Mobile Number not found',
                                              context: context);
                                        }
                                      } else {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                                email: emailController.text);

                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.pop(context);
                                        _showPasswordResetSuccessDialog(
                                            context, emailController.text);
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      String errorMessage = '';

                                      if (e is FirebaseException) {
                                        switch (e.code) {
                                          case 'invalid-email':
                                            errorMessage =
                                                'The email address is invalid.';
                                            break;
                                          case 'user-not-found':
                                            errorMessage =
                                                'No user found with this email address.';
                                            break;
                                          case 'too-many-requests':
                                            errorMessage =
                                                'Too many requests. Please try again later.';
                                            break;
                                          default:
                                            errorMessage =
                                                'An error occurred while resetting the password.';
                                        }
                                      } else {
                                        errorMessage =
                                            'An error occurred while resetting the password.';
                                      }

                                      showToast(errorMessage, context: context);
                                    }
                                  }
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextWidget(
                                  text: 'Continue',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Medium',
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showPasswordResetSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              TextWidget(
                text: 'Reset Link Sent!',
                fontSize: 18,
                fontFamily: 'Bold',
                color: Colors.black87,
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: 'We\'ve sent a password reset link to',
                fontSize: 14,
                color: Colors.grey.shade600,
                align: TextAlign.center,
              ),
              TextWidget(
                text: email,
                fontSize: 16,
                fontFamily: 'Medium',
                color: primary,
                align: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: 'Please check your email and follow the instructions.',
                fontSize: 14,
                color: Colors.grey.shade600,
                align: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: TextWidget(
                  text: 'OK',
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Medium',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
