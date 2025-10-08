import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/screens/auth/package_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/pages/business/packages_page.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_business.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/address_widget.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SignupScreen2 extends StatefulWidget {
  String id;

  SignupScreen2({super.key, required this.id});

  @override
  State<SignupScreen2> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final desc = TextEditingController();

  final pts = TextEditingController();

  final rep = TextEditingController();

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Logos/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Logos/$fileName')
            .getDownloadURL();

        setState(() {});

        Navigator.of(context).pop();
        showToast('Image uploaded!');
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

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
    final isWeb = screenWidth > 800;

    return Scaffold(
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  secondary,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/newbackground.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Juan4All 2.png',
                          height: 180,
                        ),
                        const SizedBox(height: 40),
                        TextWidget(
                          text: 'Almost There!',
                          fontSize: 36,
                          fontFamily: 'Bold',
                          color: Colors.white,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextWidget(
                          text:
                              'Complete your business profile to start accepting payments',
                          fontSize: 18,
                          fontFamily: 'Regular',
                          color: Colors.white.withOpacity(0.9),
                          align: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Form
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Business Details',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: 'Step 2 of 3: Company Information',
                      fontSize: 16,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 30),
                    // Logo upload
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            maxRadius: 60,
                            minRadius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: imageURL.isNotEmpty
                                ? NetworkImage(imageURL)
                                : null,
                            child: imageURL.isEmpty
                                ? Icon(Icons.business,
                                    size: 60, color: Colors.grey.shade400)
                                : null,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              uploadPicture('gallery');
                            },
                            icon: Icon(Icons.upload, color: primary, size: 18),
                            label: TextWidget(
                              text: 'Upload Company Logo',
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Address dropdowns
                    CustomRegionDropdownView(
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
                    const SizedBox(height: 20),
                    CustomProvinceDropdownView(
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
                    const SizedBox(height: 20),
                    CustomMunicipalityDropdownView(
                      municipalities: province?.municipalities ?? [],
                      onChanged: (value) {
                        setState(() {
                          municipality = value;
                        });
                      },
                      value: municipality,
                    ),
                    const SizedBox(height: 20),
                    // Description
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Business Description',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      maxLine: 5,
                      height: 100,
                      width: double.infinity,
                      isRequred: false,
                      controller: desc,
                      label: 'Business Description',
                    ),
                    const SizedBox(height: 20),
                    // Category dropdowns
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          isExpanded: true,
                          hint: Text(
                            'Select Business Classification',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
                                color: Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedCategory != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            isExpanded: true,
                            hint: Text(
                              'Select Classification Type',
                              style: TextStyle(
                                color: Colors.grey.shade600,
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
                                  color: Colors.black87,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Points conversion
                    TextFieldWidget(
                      inputType: TextInputType.number,
                      fontStyle: FontStyle.normal,
                      hint: 'Points Conversion (%)',
                      borderColor: Colors.grey.shade300,
                      radius: 12,
                      width: double.infinity,
                      isRequred: false,
                      controller: pts,
                      prefixIcon: Icons.monetization_on,
                      label: 'Points Conversion (%)',
                    ),
                    const SizedBox(height: 30),
                    // Next button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ButtonWidget(
                        width: double.infinity,
                        label: 'Next',
                        onPressed: () async {
                          if (desc.text != '' || rep.text != '') {
                            await FirebaseFirestore.instance
                                .collection('Business')
                                .doc(widget.id)
                                .update({
                              'logo': imageURL,
                              'address':
                                  '${municipality!.name}, ${province!.name}',
                              'desc': desc.text,
                              'clarification': _selectedSubCategory,
                              'representative': rep.text,
                              'ptsconversion': double.parse(pts.text),
                            }).whenComplete(() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PackagePage(
                                        id: widget.id,
                                      )));
                            });
                          } else {
                            showToast('All fields are required!');
                          }
                        },
                        color: primary,
                        radius: 12,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  children: [
                    // Logo with shadow
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/Juan4All 2.png',
                        height: 70,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Title
                    TextWidget(
                      text: 'Business Details',
                      fontSize: 32,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Step 2 of 3: Company Information',
                      fontSize: 15,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo upload section
                    Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: imageURL.isNotEmpty
                                  ? NetworkImage(imageURL)
                                  : null,
                              child: imageURL.isEmpty
                                  ? Icon(Icons.business,
                                      size: 50, color: Colors.grey.shade400)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  uploadPicture('gallery');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, secondary],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextWidget(
                          text: 'Upload Company Logo',
                          fontSize: 13,
                          fontFamily: 'Medium',
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Address dropdowns
                    CustomRegionDropdownView(
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
                    const SizedBox(height: 20),
                    CustomProvinceDropdownView(
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
                    const SizedBox(height: 20),
                    CustomMunicipalityDropdownView(
                      municipalities: province?.municipalities ?? [],
                      onChanged: (value) {
                        setState(() {
                          municipality = value;
                        });
                      },
                      value: municipality,
                    ),
                    const SizedBox(height: 20),
                    // Business description
                    TextFieldWidget(
                      fontStyle: FontStyle.normal,
                      hint: 'Business Description',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      maxLine: 5,
                      height: 100,
                      width: double.infinity,
                      isRequred: false,
                      controller: desc,
                      label: 'Business Description',
                    ),
                    const SizedBox(height: 20),
                    // Category dropdowns with modern styling
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          isExpanded: true,
                          hint: Text(
                            'Select Business Classification',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
                                color: Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedCategory != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            isExpanded: true,
                            hint: Text(
                              'Select Classification Type',
                              style: TextStyle(
                                color: Colors.grey.shade600,
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
                                  color: Colors.black87,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Points conversion
                    TextFieldWidget(
                      inputType: TextInputType.number,
                      fontStyle: FontStyle.normal,
                      hint: 'Points Conversion (%)',
                      borderColor: Colors.grey.shade200,
                      radius: 15,
                      width: double.infinity,
                      isRequred: false,
                      controller: pts,
                      prefixIcon: Icons.monetization_on,
                      label: 'Points Conversion (%)',
                    ),
                    const SizedBox(height: 30),
                    // Next button with gradient
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            if (desc.text != '' || rep.text != '') {
                              await FirebaseFirestore.instance
                                  .collection('Business')
                                  .doc(widget.id)
                                  .update({
                                'logo': imageURL,
                                'address':
                                    '${municipality!.name}, ${province!.name}',
                                'desc': desc.text,
                                'clarification': _selectedSubCategory,
                                'representative': rep.text,
                                'ptsconversion': double.parse(pts.text),
                              }).whenComplete(() {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PackagePage(
                                          id: widget.id,
                                        )));
                              });
                            } else {
                              showToast('All fields are required!');
                            }
                          },
                          child: Center(
                            child: TextWidget(
                              text: 'Next',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
