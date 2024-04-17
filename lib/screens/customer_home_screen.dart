import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/pages/business/inventory_page.dart';
import 'package:juan_million/screens/pages/business/points_page.dart';
import 'package:juan_million/screens/pages/business/settings_page.dart';
import 'package:juan_million/screens/pages/business/wallet_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(1000),
                  bottomRight: Radius.circular(1000),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextWidget(
                            text: 'Hello ka-Juan!',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.qr_code,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextWidget(
                        text: 'Total Points',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: '135',
                            fontFamily: 'Bold',
                            fontSize: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const InventoryPage()));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                Icons.add,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWidget(
                      text: 'Store',
                      fontSize: 18,
                      fontFamily: 'Bold',
                    ),
                    TextWidget(
                      text: 'See all',
                      color: blue,
                      fontSize: 14,
                      fontFamily: 'Bold',
                    ),
                  ],
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWidget(
                      text: 'Promo & Deals',
                      fontSize: 18,
                      fontFamily: 'Bold',
                    ),
                    TextWidget(
                      text: 'See more',
                      color: blue,
                      fontSize: 14,
                      fontFamily: 'Bold',
                    ),
                  ],
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
                            width: 265,
                            child: Image.asset(
                              'assets/images/Card.png',
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
        ],
      ),
    );
  }
}
