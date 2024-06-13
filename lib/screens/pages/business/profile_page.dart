import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class ProfikePage extends StatelessWidget {
  dynamic data;

  ProfikePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  text: 'Business Info',
                  fontSize: 18,
                ),
                const SizedBox(
                  width: 50,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Icon(
              Icons.account_circle_outlined,
              color: blue,
              size: 125,
            ),
            TextWidget(
              text: data['name'],
              fontSize: 18,
              color: Colors.black,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Card(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  tileColor: Colors.white,
                  leading: TextWidget(
                    text: 'Points balance',
                    fontSize: 13,
                    color: blue,
                    fontFamily: 'Medium',
                  ),
                  trailing: TextWidget(
                    text: ' ${data['pts']} points',
                    fontSize: 16,
                    color: primary,
                    fontFamily: 'Bold',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Card(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  tileColor: Colors.white,
                  leading: TextWidget(
                    text: 'Points Receive',
                    fontSize: 13,
                    color: blue,
                    fontFamily: 'Medium',
                  ),
                  trailing: TextWidget(
                    text: ' ${data['ptsreceive']} points',
                    fontSize: 16,
                    color: primary,
                    fontFamily: 'Bold',
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
                  TextWidget(
                    text: 'All Transactions',
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: 0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                              ),
                              tileColor: Colors.white,
                              leading: Icon(
                                Icons.volunteer_activism_outlined,
                                color: secondary,
                                size: 32,
                              ),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'February 2, 2024',
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontFamily: 'Medium',
                                  ),
                                  TextWidget(
                                    text: 'Bought 25 points',
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
