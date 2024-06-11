import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/services/add_business.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Image.asset(
                'assets/images/Juan4All 2.png',
                height: 200,
              ),
            ),
            Center(
              child: TextWidget(
                text: 'Select payment method',
                fontSize: 24,
                fontFamily: 'Bold',
                color: primary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  showToast('Paypal is currently unavailable');
                },
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/paypal-2.png',
                        height: 50,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      TextWidget(
                        text: 'Paypal',
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 30,
                        ),
                      ),
                      const Icon(
                        Icons.radio_button_off_rounded,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Image.asset(
                        'assets/images/image 15.png',
                        height: 50,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      TextWidget(
                        text: 'GCash',
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 30,
                        ),
                      ),
                      const Icon(
                        Icons.radio_button_checked_rounded,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  showToast('Apple Pay is currently unavailable');
                },
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Image.asset(
                        'assets/images/apple-pay.png',
                        height: 50,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      TextWidget(
                        text: 'Apple Pay',
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 30,
                        ),
                      ),
                      const Icon(
                        Icons.radio_button_off_outlined,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ButtonWidget(
                width: 325,
                label: 'Continue',
                onPressed: () {
                  showToast('Payment method not available!');
                },
              ),
            ),
            const SizedBox(
              height: 20,
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
