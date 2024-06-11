import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/customer_signup_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/Ellipse 7.png',
              width: double.infinity,
            ),
            Image.asset(
              'assets/images/Juan4All 2.png',
              height: 200,
            ),
            TextWidget(
              text: 'Hello ka-Juan!',
              fontSize: 32,
              fontFamily: 'Bold',
              color: primary,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(
              fontStyle: FontStyle.normal,
              hint: 'Email',
              borderColor: blue,
              radius: 12,
              width: 350,
              prefixIcon: Icons.person_3_outlined,
              isRequred: false,
              controller: username,
              label: 'Email',
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
            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              width: 350,
              label: 'Log in',
              onPressed: () {
                login(context);
              },
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.text, password: password.text);

      if (widget.inCustomer) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const CustomerHomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const BusinessHomeScreen()));
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
