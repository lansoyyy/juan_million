import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/screens/pages/store_page.dart';
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
        elevation: 0,
        title: TextWidget(
          text: 'Affiliate Locator',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Add search functionality
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    nameSearched = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search affiliates...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Enhanced filter section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  TextWidget(
                    text: 'Filters',
                    fontSize: 16,
                    fontFamily: 'Bold',
                  ),
                ],
              ),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      // Region dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
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
                      const SizedBox(height: 15),

                      // Province dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
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
                      const SizedBox(height: 15),

                      // Municipality dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
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
                      const SizedBox(height: 15),

                      // Category dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          hint: Text(
                            'Select Business Classification',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          value: _selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                              _selectedSubCategory = null;
                            });
                          },
                          items: _categoryOptions.keys.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: TextWidget(
                                text: category,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Subcategory dropdown
                      if (_selectedCategory != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            hint: Text(
                              'Select Clarification Type',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
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
                                  color: Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Enhanced business listings section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: StreamBuilder<QuerySnapshot>(
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
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      ));
                    }

                    final data = snapshot.requireData;

                    if (data.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            TextWidget(
                              text: 'No affiliates found',
                              fontSize: 18,
                              fontFamily: 'Medium',
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 10),
                            TextWidget(
                              text: 'Try adjusting your filters',
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to store page or show details
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    // Business logo with better styling
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          data.docs[index]['logo'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.storefront,
                                              size: 40,
                                              color: Colors.grey.shade400,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    // Business details with better layout
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: data.docs[index]['name'],
                                            fontSize: 18,
                                            fontFamily: 'Bold',
                                            color: Colors.black87,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: TextWidget(
                                                  text: data.docs[index]
                                                      ['clarification'],
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: TextWidget(
                                                  text: data.docs[index]
                                                      ['address'],
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.email,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: TextWidget(
                                                  text: data.docs[index]
                                                      ['email'],
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // View details button
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
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
                    );
                  }),
            ),
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
