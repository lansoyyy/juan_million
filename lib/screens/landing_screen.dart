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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/newbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: Image.asset(
                    'assets/images/Juan4All 2.png',
                    height: 200,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                // Account selection cards
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    height: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Customer Account Card
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                        inCustomer: true,
                                      )));
                            },
                            onTapDown: (_) {
                              // Add visual feedback on tap
                            },
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 320,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_circle_outlined,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextWidget(
                                      text: 'Customer\nAccount',
                                      maxLines: 2,
                                      fontSize: 20,
                                      fontFamily: 'Bold',
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextWidget(
                                        text:
                                            'For personal transactions and payments',
                                        fontSize: 12,
                                        fontFamily: 'Regular',
                                        color: Colors.white.withOpacity(0.8),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Business Account Card
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                        inCustomer: false,
                                      )));
                            },
                            child: Container(
                              height: 320,
                              width: 160,
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.business_center_outlined,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextWidget(
                                    text: 'Business\nAccount',
                                    maxLines: 2,
                                    fontSize: 20,
                                    fontFamily: 'Bold',
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: TextWidget(
                                      text: 'For merchants and business owners',
                                      fontSize: 12,
                                      fontFamily: 'Regular',
                                      color: Colors.white.withOpacity(0.8),
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                // Footer text
                TextWidget(
                  text: 'Secure • Fast • Reliable',
                  fontSize: 14,
                  fontFamily: 'Medium',
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
