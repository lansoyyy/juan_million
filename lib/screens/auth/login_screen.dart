import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/customer_signup_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/services/add_user.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 225,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/newbackground.png',
                  ),
                ),
                border: Border.all(color: blue, width: 10),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                    150,
                  ),
                  bottomRight: Radius.circular(
                    150,
                  ),
                ),
              ),
            ),
            Image.asset(
              'assets/images/Juan4All 2.png',
              height: 200,
            ),
            TextWidget(
              text: widget.inCustomer ? 'Hello ka-Juan!' : 'Hello ka-Negosyo',
              fontSize: 32,
              fontFamily: 'Bold',
              color: primary,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(
              fontStyle: FontStyle.normal,
              hint: 'Email/Phone Number',
              borderColor: blue,
              radius: 12,
              width: 350,
              prefixIcon: Icons.person_3_outlined,
              isRequred: false,
              controller: username,
              label: 'Email/Phone Number',
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldWidget(
              showEye: true,
              isObscure: true,
              fontStyle: FontStyle.normal,
              hint: 'Password',
              borderColor: blue,
              radius: 12,
              width: 350,
              prefixIcon: Icons.lock_open_outlined,
              isRequred: false,
              controller: password,
              label: 'Password',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: ((context) {
                        final formKey = GlobalKey<FormState>();
                        final TextEditingController emailController =
                            TextEditingController();

                        return AlertDialog(
                          backgroundColor: Colors.grey[100],
                          title: TextWidget(
                            text: 'Forgot Password',
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFieldWidget(
                                  hint: 'Email',
                                  textCapitalization: TextCapitalization.none,
                                  inputType: TextInputType.emailAddress,
                                  label: 'Email',
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email address';
                                    }
                                    final emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: (() {
                                Navigator.pop(context);
                              }),
                              child: TextWidget(
                                text: 'Cancel',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: (() async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    Navigator.pop(context);
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: emailController.text);
                                    showToast(
                                        'Password reset link sent to ${emailController.text}');
                                  } catch (e) {
                                    String errorMessage = '';

                                    if (e is FirebaseException) {
                                      switch (e.code) {
                                        case 'invalid-email':
                                          errorMessage =
                                              'The email address is invalid.';
                                          break;
                                        case 'user-not-found':
                                          errorMessage =
                                              'The user associated with the email address is not found.';
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
                                    Navigator.pop(context);
                                  }
                                }
                              }),
                              child: TextWidget(
                                text: 'Continue',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  },
                  child: TextWidget(
                    text: 'Forgot Password?',
                    fontSize: 12,
                    color: blue,
                    fontFamily: 'Medium',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ButtonWidget(
              width: 350,
              label: 'Log in',
              onPressed: () async {
                var document = FirebaseFirestore.instance.doc('App/versions');
                var snapshot = await document.get();

                if (snapshot.data()!['version'] == version) {
                  login(context);
                } else {
                  showToast('Cannot Proceed! Your app version is outdated!');
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 150,
                  child: Divider(),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextWidget(
                  text: 'or',
                  fontSize: 12,
                  color: blue,
                ),
                const SizedBox(
                  width: 10,
                ),
                const SizedBox(
                  width: 150,
                  child: Divider(),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                googleLogin();
              },
              child: Container(
                width: 325,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    50,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/googlelogo.png',
                        width: 25,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      TextWidget(
                        text: 'Continue with Google',
                        fontSize: 14,
                        color: blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: 'Don’t have an account yet?',
                  fontSize: 12,
                  color: blue,
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
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    color: primary,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  login(context) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: isPhoneNumber(username.text)
              ? '${username.text}@gmail.com'
              : username.text,
          password: password.text);

      if (widget.inCustomer) {
        if (!isPhoneNumber(username.text)) {
          if (user.user!.emailVerified) {
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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
            (route) {
              return false;
            },
          );
        }
      } else {
        var document =
            FirebaseFirestore.instance.doc('Business/${user.user!.uid}');
        var snapshot = await document.get();
        if (snapshot.data()!['verified'] == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BusinessHomeScreen()),
            (route) {
              return false;
            },
          );
        } else {
          showToast('Request grant access!');
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
                  '');
            } catch (e) {
              print('Error: $e');
              // Handle the error accordingly
            }
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
}
