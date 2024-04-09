import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  final name = TextEditingController();
  final email = TextEditingController();

  final password = TextEditingController();
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
                text: 'Choose a business package',
                fontSize: 24,
                fontFamily: 'Bold',
                color: primary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Starter',
                    fontSize: 18,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 150,
                    width: 500,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'P200',
                                      fontSize: 14,
                                      fontFamily: 'Medium',
                                      color: blue,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          text: '250',
                                          fontSize: 38,
                                          fontFamily: 'Bold',
                                          color: blue,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        TextWidget(
                                          text: 'pts',
                                          fontSize: 12,
                                          fontFamily: 'Bold',
                                          color: blue,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: secondary,
                                          size: 15,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        TextWidget(
                                          text: 'Limited offer',
                                          fontSize: 10,
                                          fontFamily: 'Bold',
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Premium',
                    fontSize: 18,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 150,
                    width: 500,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'P200',
                                      fontSize: 14,
                                      fontFamily: 'Medium',
                                      color: blue,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          text: '250',
                                          fontSize: 38,
                                          fontFamily: 'Bold',
                                          color: blue,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        TextWidget(
                                          text: 'pts',
                                          fontSize: 12,
                                          fontFamily: 'Bold',
                                          color: blue,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: secondary,
                                          size: 15,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        TextWidget(
                                          text: 'Limited offer',
                                          fontSize: 10,
                                          fontFamily: 'Bold',
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ButtonWidget(
                width: 325,
                label: 'Next',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PaymentScreen()));
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
