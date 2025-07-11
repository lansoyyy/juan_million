import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/auth/signup_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/utlis/dragonpay.dart';
import 'package:juan_million/widgets/dragonpay_screen.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

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
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
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
                        // final result = await Navigator.push<bool>(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const DragonPayWebView()),
                        // );
                        // if (result != null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text(result
                        //           ? 'Payment Successful!'
                        //           : 'Payment Failed or Canceled'),
                        //       backgroundColor:
                        //           result ? Colors.green : Colors.red,
                        //       duration: const Duration(seconds: 3),
                        //     ),
                        //   );
                        // }
                      },
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 300,
                          width: 150,
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
                        // showToast('Under development');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  inCustomer: false,
                                )));
                      },
                      child: Container(
                        height: 300,
                        width: 150,
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
            ),
          ],
        ),
      ),
    );
  }
}
