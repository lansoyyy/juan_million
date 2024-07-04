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
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              CircleAvatar(
                maxRadius: 75,
                minRadius: 75,
                backgroundImage: NetworkImage(imageURL),
              ),
              TextButton(
                onPressed: () {
                  uploadPicture('gallery');
                },
                child: TextWidget(
                  text: 'Company Logo',
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: primary,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 350,
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
                width: 350,
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
                width: 350,
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
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Business Description',
                borderColor: blue,
                radius: 12,
                maxLine: 5,
                height: 100,
                width: 350,
                isRequred: false,
                controller: desc,
                label: 'Business Description',
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 10, right: 10),
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
                            'Select Business Clarification',
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
                          items: _categoryOptions.keys.map((String category) {
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
              const SizedBox(
                height: 10,
              ),
              TextFieldWidget(
                inputType: TextInputType.number,
                fontStyle: FontStyle.normal,
                hint: 'Points Conversion',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: pts,
                prefixIcon: Icons.monetization_on,
                label: 'Points Conversion',
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 350,
                label: 'Next',
                onPressed: () async {
                  if (desc.text != '' || rep.text != '') {
                    await FirebaseFirestore.instance
                        .collection('Business')
                        .doc(widget.id)
                        .update({
                      'logo': imageURL,
                      'address': '${municipality!.name}, ${province!.name}',
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
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
