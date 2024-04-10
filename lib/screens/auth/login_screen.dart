import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/screens/home_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
              hint: 'Username',
              borderColor: blue,
              radius: 12,
              width: 350,
              prefixIcon: Icons.person_3_outlined,
              isRequred: false,
              controller: username,
              label: 'Username',
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignupScreen()));
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
}
