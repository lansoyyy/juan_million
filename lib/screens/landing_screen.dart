import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Juan4All 2.png',
              height: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 450,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                inCustomer: true,
                              )));
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 300,
                        width: 175,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextWidget(
                              text: 'Customer\naccount',
                              maxLines: 2,
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                inCustomer: false,
                              )));
                    },
                    child: Container(
                      height: 300,
                      width: 175,
                      decoration: BoxDecoration(
                        color: secondary,
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.business_center_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextWidget(
                            text: 'Business\naccount',
                            maxLines: 2,
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.white,
                          ),
                        ],
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
