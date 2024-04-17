import 'package:flutter/material.dart';
import 'package:juan_million/screens/pages/business/profile_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final name = TextEditingController();
  final email = TextEditingController();

  final password = TextEditingController();

  final pts = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                      )),
                ),
                TextWidget(
                  text: 'Settings',
                  fontSize: 18,
                ),
                const SizedBox(
                  width: 50,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextFieldWidget(
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
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextFieldWidget(
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
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextFieldWidget(
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
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Points Conversion',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: pts,
                prefixIcon: null,
                label: 'Points Conversion',
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ButtonWidget(
                width: 350,
                label: 'Save',
                onPressed: () {},
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'More',
                    color: blue,
                    fontSize: 14,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Card(
                    elevation: 3,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ProfikePage()));
                      },
                      tileColor: Colors.white,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.person_2_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      title: TextWidget(
                        text: 'My Account',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.logout,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      title: TextWidget(
                        text: 'Logout',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
