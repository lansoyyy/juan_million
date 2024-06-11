import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/auth/package_screen.dart';
import 'package:juan_million/screens/business_home_screen.dart';
import 'package:juan_million/screens/pages/store_page.dart';
import 'package:juan_million/services/add_business.dart';
import 'package:juan_million/utlis/colors.dart';
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
  final address = TextEditingController();
  final desc = TextEditingController();
  final clarification = TextEditingController();

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
                  text: 'Upload Logo',
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: primary,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Business Address',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.location_on_rounded,
                controller: address,
                label: 'Business Address',
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
              TextFieldWidget(
                prefixIcon: Icons.info_outline,
                fontStyle: FontStyle.normal,
                hint: 'Business Clarification (Retail, Cafe & Resto, Etc.)',
                borderColor: blue,
                radius: 12,
                width: 350,
                controller: clarification,
                label: 'Clarification',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                prefixIcon: Icons.person,
                fontStyle: FontStyle.normal,
                hint: 'Business Representative',
                borderColor: blue,
                radius: 12,
                width: 350,
                controller: clarification,
                label: 'Business Representative',
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 350,
                label: 'Next',
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('Business')
                      .doc(widget.id)
                      .update({
                    'logo': imageURL,
                    'address': address.text,
                    'desc': desc.text,
                    'clarification': clarification.text,
                    'representative': rep.text,
                  }).whenComplete(() {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => StorePage(
                              inbusiness: true,
                            )));
                  });
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
