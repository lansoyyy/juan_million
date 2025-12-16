import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Modern Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 30 : 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Affiliate Locator',
                                fontSize: isDesktop ? 28 : 24,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: 'Find businesses near you',
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Modern Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
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
                          hintText: 'Search affiliates by name...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: primary,
                            size: 24,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded,
                                      color: Colors.grey.shade400),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      nameSearched = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Modern Filter Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, secondary]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: TextWidget(
                text: 'Advanced Filters',
                fontSize: 16,
                fontFamily: 'Bold',
                color: Colors.black87,
              ),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  stream: _getBusinessQuery().snapshots(),
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
                    final List<DocumentSnapshot> filteredDocs =
                        data.docs.where((doc) {
                      final Map<String, dynamic>? map =
                          doc.data() as Map<String, dynamic>?;
                      final dynamic verified = map?['verified'];
                      return verified == true ||
                          verified == 'true' ||
                          verified == 1;
                    }).toList();

                    if (filteredDocs.isEmpty) {
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

                    return isDesktop
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              return _buildBusinessCard(
                                  filteredDocs[index], true);
                            },
                          )
                        : ListView.builder(
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              return _buildBusinessCard(
                                  filteredDocs[index], false);
                            },
                          );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Query<Map<String, dynamic>> _getBusinessQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Business')
        .where('verified', isEqualTo: true);

    if (municipality == null) {
      if (_selectedSubCategory != null && _selectedSubCategory!.isNotEmpty) {
        query = query.where('clarification', isEqualTo: _selectedSubCategory);
      }
    } else {
      query = query.where('address',
          isEqualTo: '${municipality!.name}, ${province!.name}');
    }

    return query;
  }

  Widget _buildBusinessCard(DocumentSnapshot data, bool isDesktop) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 15),
      child: GestureDetector(
        onTap: () {
          _showBusinessDetailsDialog(data);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isDesktop
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Business logo
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primary.withOpacity(0.1),
                                  secondary.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                data['logo'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.storefront_rounded,
                                    size: 35,
                                    color: primary,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: data['name'],
                                  fontSize: 18,
                                  fontFamily: 'Bold',
                                  color: Colors.black87,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primary.withOpacity(0.1),
                                        secondary.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextWidget(
                                    text: data['clarification'],
                                    fontSize: 11,
                                    fontFamily: 'Bold',
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextWidget(
                              text: data['address'],
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextWidget(
                              text: data['email'],
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Business logo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.1),
                              secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            data['logo'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.storefront_rounded,
                                size: 45,
                                color: primary,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Business details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: data['name'],
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primary.withOpacity(0.1),
                                    secondary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextWidget(
                                text: data['clarification'],
                                fontSize: 12,
                                fontFamily: 'Bold',
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextWidget(
                                    text: data['address'],
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextWidget(
                                    text: data['email'],
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.1),
                              secondary.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
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
                      showToast('Your wallet balance is not enough!',
                          context: context);
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

  void _showBusinessDetailsDialog(DocumentSnapshot businessData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Business Details',
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Business logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.1),
                          secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        businessData['logo'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.storefront_rounded,
                            size: 60,
                            color: primary,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Business name
                Center(
                  child: TextWidget(
                    text: businessData['name'] ?? 'N/A',
                    fontSize: 22,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),

                // Business email
                Center(
                  child: TextWidget(
                    text: businessData['email'] ?? 'N/A',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Business details section
                _buildDetailSection(
                    'Address', businessData['address'] ?? 'N/A'),
                _buildDetailSection('Description',
                    businessData['desc'] ?? 'No description available'),
                _buildDetailSection('Business Classification',
                    businessData['clarification'] ?? 'N/A'),
                _buildDetailSection(
                    'Representative', businessData['representative'] ?? 'N/A'),
                _buildDetailSection(
                    'Phone', businessData['phone'] ?? 'Not provided'),

                const SizedBox(height: 15),

                // Verification status
                Row(
                  children: [
                    Icon(
                      businessData['verified'] == true
                          ? Icons.verified_rounded
                          : Icons.pending_rounded,
                      color: businessData['verified'] == true
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: businessData['verified'] == true
                          ? 'Verified Business'
                          : 'Pending Verification',
                      fontSize: 14,
                      fontFamily: 'Medium',
                      color: businessData['verified'] == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        label: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        radius: 10,
                        color: Colors.grey.shade300,
                        textColor: Colors.black87,
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
  }

  Widget _buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextWidget(
          text: label,
          fontSize: 12,
          fontFamily: 'Regular',
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 3),
        TextWidget(
          text: value,
          fontSize: 16,
          fontFamily: 'Medium',
          color: Colors.black87,
        ),
      ],
    );
  }
}
