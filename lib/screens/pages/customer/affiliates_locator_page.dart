import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/address_widget.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:juan_million/widgets/toast_widget.dart';

class AffiliateLocatorPage extends StatefulWidget {
  const AffiliateLocatorPage({super.key});

  @override
  State<AffiliateLocatorPage> createState() => _AffiliateLocatorPageState();
}

class _AffiliateLocatorPageState extends State<AffiliateLocatorPage> {
  final searchController = TextEditingController();
  String nameSearched = '';

  Region? region;
  Province? province;
  Municipality? municipality;

  String? _selectedCategory;
  String? _selectedSubCategory;

  final Map<String, List<String>> _categoryOptions = {
    'Retail': [
      'Grocery Store',
      'Electronic & Gadgets',
      'Apparel & Fashion',
      'Cosmetics & Beauty',
      'Toys & Games',
      'Books & Stationary',
      'Sports & Fitness',
      'Home Improvement',
      'Pet Supplies',
      'Agri- Products',
      'Crafts & Hobbies',
      'Specialty Retail',
      'Others'
    ],
    'Services': [
      'Personal Care',
      'Professional Services',
      'Health & Wellness',
      'Educational Services',
      'Home Services',
      'Automobile',
      'Laundry',
      'Fuel Station',
      'Transportation',
      'Others'
    ],
    'Cafe and Resto': [
      'Coffee Shops',
      'Casual Dining',
      'Fine Dining',
      'Bakeries & Dessert Shops',
      'Others'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: blue,
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                title: TextWidget(
                  text: 'Filters',
                  fontSize: 18,
                  fontFamily: 'Bold',
                ),
                leading: const Icon(
                  Icons.sort,
                ),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CustomRegionDropdownView(
                        onChanged: (Region? value) {
                          setState(() {
                            if (region != value) {
                              province = null;
                              municipality = null;
                            }
                            region = value;
                          });
                        },
                        value: region),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomProvinceDropdownView(
                      provinces: region?.provinces ?? [],
                      onChanged: (Province? value) {
                        setState(() {
                          if (province != value) {
                            municipality = null;
                          }
                          province = value;
                        });
                      },
                      value: province,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomMunicipalityDropdownView(
                      municipalities: province?.municipalities ?? [],
                      onChanged: (value) {
                        setState(() {
                          municipality = value;
                        });
                      },
                      value: municipality,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.5),
                            border: Border.all(
                              color: blue,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: DropdownButton<String>(
                              underline: const SizedBox(),
                              hint: Text(
                                'Select Business Classification',
                                style: TextStyle(
                                  color: blue,
                                ),
                              ),
                              value: _selectedCategory,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                  _selectedSubCategory = null;
                                });
                              },
                              items:
                                  _categoryOptions.keys.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: TextWidget(
                                    text: category,
                                    fontSize: 14,
                                    color: blue,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (_selectedCategory != null)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.5),
                              border: Border.all(
                                color: blue,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: DropdownButton<String>(
                                underline: const SizedBox(),
                                hint: Text(
                                  'Select Clarification Type',
                                  style: TextStyle(
                                    color: blue,
                                  ),
                                ),
                                value: _selectedSubCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSubCategory = newValue;
                                  });
                                },
                                items: _categoryOptions[_selectedCategory]!
                                    .map((String subCategory) {
                                  return DropdownMenuItem<String>(
                                    value: subCategory,
                                    child: TextWidget(
                                      text: subCategory,
                                      fontSize: 14,
                                      color: blue,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: municipality == null
                      ? FirebaseFirestore.instance
                          .collection('Business')
                          .where('clarification',
                              isEqualTo: _selectedSubCategory)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Business')
                          .where('clarification',
                              isEqualTo: _selectedSubCategory)
                          .where('address',
                              isEqualTo:
                                  '${municipality!.name}, ${province!.name}')
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(child: Text('Error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        )),
                      );
                    }

                    final data = snapshot.requireData;

                    return SizedBox(
                      height: 500,
                      child: ListView.builder(
                        itemCount: data.docs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Center(
                                              child: Image.network(
                                                data.docs[index]['logo'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: TextWidget(
                                                text: data.docs[index]['name'],
                                                fontSize: 24,
                                                color: blue,
                                                fontFamily: 'Bold',
                                              ),
                                            ),
                                            TextWidget(
                                              text:
                                                  'Classification: ${data.docs[index]['clarification']}',
                                              fontSize: 11,
                                              color: blue,
                                              fontFamily: 'Regular',
                                            ),
                                            TextWidget(
                                              text:
                                                  'Email: ${data.docs[index]['email']}',
                                              fontSize: 11,
                                              color: blue,
                                              fontFamily: 'Regular',
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  verifyDialog(data, int mywallet) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 150,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              data['logo'],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: TextWidget(
                        text: data['name'],
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                    ),
                    Center(
                      child: TextWidget(
                        text: data['email'],
                        fontSize: 11,
                        fontFamily: 'Regular',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Address',
                          fontSize: 10,
                          fontFamily: 'Regular',
                          color: Colors.grey,
                        ),
                        TextWidget(
                          text: data['address'],
                          fontSize: 16,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Business Clarification',
                          fontSize: 10,
                          fontFamily: 'Regular',
                          color: Colors.grey,
                        ),
                        TextWidget(
                          text: data['clarification'],
                          fontSize: 16,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: data['representative'],
                          fontSize: 10,
                          fontFamily: 'Regular',
                          color: Colors.grey,
                        ),
                        TextWidget(
                          text: 'Address',
                          fontSize: 16,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: blue,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Payment',
                          fontSize: 10,
                          fontFamily: 'Regular',
                          color: Colors.grey,
                        ),
                        TextWidget(
                          text: AppConstants.formatNumberWithPeso(
                              data['packagePayment']),
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.of(context).pop();

                    if (mywallet >= 2000) {
                      await FirebaseFirestore.instance
                          .collection('Business')
                          .doc(data.id)
                          .update({
                        'verified': true,
                        // 'wallet': 2000,
                      });

                      await FirebaseFirestore.instance
                          .collection('Coordinator')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'wallet': FieldValue.increment(-2000),
                      });
                    } else {
                      showToast('Your wallet balance is not enough!');
                    }
                  },
                  child: Text(
                    'Verify Affiliate',
                    style: TextStyle(
                        color: blue,
                        fontFamily: 'Bold',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }
}
