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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/newbackground.png'),
              fit: BoxFit.cover,
              opacity: 0.35),
          color: Colors.black,
        ),
        child: Column(
          children: [
            // Header with improved design
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withOpacity(0.8),
                      primary.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      child: Image.asset(
                        'assets/images/Juan4All 2.png',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextWidget(
                      text: widget.inCustomer
                          ? 'Hello ka-Juan!'
                          : 'Hello ka-Negosyo',
                      fontSize: 28,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Form container with improved styling
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFieldWidget(
                    fontStyle: FontStyle.normal,
                    hint: 'Enter your email',
                    borderColor: Colors.grey.shade300,
                    radius: 15,
                    width: double.infinity,
                    prefixIcon: Icons.email_outlined,
                    isRequred: false,
                    controller: username,
                    label: 'Email Address',
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                    showEye: true,
                    isObscure: true,
                    fontStyle: FontStyle.normal,
                    hint: 'Enter your password',
                    borderColor: Colors.grey.shade300,
                    radius: 15,
                    width: double.infinity,
                    prefixIcon: Icons.lock_outline,
                    isRequred: false,
                    controller: password,
                    label: 'Password',
                  ),
                  // Forgot password with better alignment
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

                  const SizedBox(height: 25),

                  // Login button with improved styling
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ButtonWidget(
                      width: double.infinity,
                      label: 'Log in',
                      onPressed: () async {
                        var document =
                            FirebaseFirestore.instance.doc('App/versions');
                        var snapshot = await document.get();

                        if (snapshot.data()!['version'] == version) {
                          login(context);
                        } else {
                          showToast(
                              'Cannot Proceed! Your app version is outdated!');
                        }
                      },
                      color: primary,
                      radius: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Social login section with improved design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      text: 'or continue with',
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
            ),

            const SizedBox(height: 20),

            // Google login button with improved design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
              ),
            ),

            const SizedBox(height: 30),

            // Sign up section with improved styling
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: "Don't have an account yet?",
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                TextButton(
                  onPressed: () {
                    if (widget.inCustomer) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CustomerSignupScreen()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                    }
                  },
                  child: TextWidget(
                    text: 'Create account',
                    fontSize: 16,
                    fontFamily: 'Medium',
                    color: primary,
                  ),
                ),
              ],
            ),
          ],
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
              showToast('Cannot proceed! Email not verified');
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
                showToast('Request grant access!');
              }
            } else {
              showToast('Cannot proceed! Email not verified');
            }
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            showToast("No user found with that email.");
          } else if (e.code == 'wrong-password') {
            showToast("Wrong password provided for that user.");
          } else if (e.code == 'invalid-email') {
            showToast("Invalid email provided.");
          } else if (e.code == 'user-disabled') {
            showToast("User account has been disabled.");
          } else {
            showToast("An error occurred: ${e.message}");
          }
        } on Exception catch (e) {
          showToast("An error occurred: $e");
        }
      } else {
        showToast('Cannot proceed! Mobile Number not found');
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
            showToast('Cannot proceed! Email not verified');
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
              showToast('Request grant access!');
            }
          } else {
            showToast('Cannot proceed! Email not verified');
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showToast("No user found with that email.");
        } else if (e.code == 'wrong-password') {
          showToast("Wrong password provided for that user.");
        } else if (e.code == 'invalid-email') {
          showToast("Invalid email provided.");
        } else if (e.code == 'user-disabled') {
          showToast("User account has been disabled.");
        } else {
          showToast("An error occurred: ${e.message}");
        }
      } on Exception catch (e) {
        showToast("An error occurred: $e");
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
                                          showToast('Mobile Number not found');
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

                                      showToast(errorMessage);
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
