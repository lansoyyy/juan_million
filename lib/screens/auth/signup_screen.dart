import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/package_screen.dart';
import 'package:juan_million/screens/auth/signup_screen2.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/services/add_business.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/images/Juan4All 2.png',
                height: 200,
              ),
              TextWidget(
                text: 'Sign up as business',
                fontSize: 32,
                fontFamily: 'Bold',
                color: primary,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Business Name',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.person_3_outlined,
                controller: name,
                label: 'Business Name',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Business Email',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: email,
                prefixIcon: Icons.email_outlined,
                label: 'Business Email',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
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
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 350,
                label: 'Next',
                onPressed: () {
                  register(context);
                },
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      // addUser(name.text, email.text);
      addBusiness(name.text, email.text, '', '', '', '', '');

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
  }
}
