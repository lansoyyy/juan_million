import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerInventoryPage extends StatefulWidget {
  const CustomerInventoryPage({super.key});

  @override
  State<CustomerInventoryPage> createState() => _CustomerInventoryPageState();
}

class _CustomerInventoryPageState extends State<CustomerInventoryPage> {
  final searchController = TextEditingController();
  String nameSearched = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: TextWidget(
                  text: 'Bayanihan Fund',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Center(
                child: TextWidget(
                  text: '100',
                  fontFamily: 'Bold',
                  fontSize: 75,
                  color: Colors.white,
                ),
              ),
              Center(
                child: Column(
                  children: [
                    TextWidget(
                      text: '2 slots',
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Your Slots',
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Bold',
                        ),
                        TextWidget(
                          text: '2/10 per day',
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                    TextWidget(
                      text: '85%',
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Regular',
                    ),
                    Container(
                      width: double.infinity,
                      height: 15,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextWidget(
                      text: '25%',
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Regular',
                    ),
                    Container(
                      width: double.infinity,
                      height: 15,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextWidget(
                      text: 'Community',
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    maxRadius: 40,
                                    minRadius: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Center(
                                            child: TextWidget(
                                              text: i == 0
                                                  ? '2'
                                                  : i == 1
                                                      ? '1'
                                                      : '3',
                                              fontSize: 12,
                                              fontFamily: 'Bold',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextWidget(
                                    text: 'John Doe',
                                    fontSize: 18,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text: '40 pts',
                                    fontSize: 14,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                              ),
                              tileColor: Colors.white,
                              leading: SizedBox(
                                height: 50,
                                width: 300,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget(
                                      text: '${index + 1}',
                                      fontSize: 11,
                                      color: Colors.black,
                                      fontFamily: 'Bold',
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const CircleAvatar(
                                      maxRadius: 25,
                                      minRadius: 25,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    TextWidget(
                                      text: 'John Doe',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Bold',
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
      ),
    );
  }
}
