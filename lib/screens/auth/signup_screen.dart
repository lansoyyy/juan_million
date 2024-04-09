import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/package_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

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
        child: Column(
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PackageScreen()));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: Divider(
                    color: primary,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextWidget(
                  text: 'OR',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 150,
                  child: Divider(
                    color: primary,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'assets/images/fblogo.png',
                      height: 35,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'assets/images/googlelogo.png',
                      height: 35,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: primary,
                      size: 32,
                    ),
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
