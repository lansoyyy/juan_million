import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:juan_million/models/municipality_model.dart';
import 'package:juan_million/models/province_model.dart';
import 'package:juan_million/models/region_model.dart';
import 'package:juan_million/screens/auth/login_screen.dart';
import 'package:juan_million/screens/auth/package_screen.dart';
import 'package:juan_million/screens/customer_home_screen.dart';
import 'package:juan_million/services/add_referal.dart';
import 'package:juan_million/services/add_user.dart';
import 'package:juan_million/utlis/app_common.dart';
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

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();

  final ref = TextEditingController();

  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  final nickname = TextEditingController();

  final number = TextEditingController();

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
            .ref('Pictures/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/Juan4All 2.png',
                height: 200,
              ),
              TextWidget(
                text: 'Register as Customer',
                fontSize: 32,
                fontFamily: 'Bold',
                color: primary,
              ),
              const SizedBox(
                height: 20,
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
                  text: 'Upload Picture',
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
                hint: 'Firstname',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.person_3_outlined,
                controller: fname,
                label: 'Firstname',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Lastname',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.person_3_outlined,
                controller: lname,
                label: 'Lastname',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Nickname',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.person_3_outlined,
                controller: nickname,
                label: 'Nickname',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Mobile Number',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: true,
                inputType: TextInputType.number,
                maxLength: 11,
                height: 70,
                prefixIcon: Icons.phone,
                controller: number,
                label: 'Mobile Number',
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
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
                hint: 'Email',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: email,
                prefixIcon: Icons.email,
                label: 'Email',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                showEye: true,
                isObscure: true,
                prefixIcon: Icons.lock_open_outlined,
                fontStyle: FontStyle.normal,
                hint: 'Password',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: password,
                label: 'Password',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                showEye: true,
                isObscure: true,
                prefixIcon: Icons.lock_open_outlined,
                fontStyle: FontStyle.normal,
                hint: 'Confirm Password',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                controller: confirmpassword,
                label: 'Confirm Password',
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                fontStyle: FontStyle.normal,
                hint: 'Referral Code',
                borderColor: blue,
                radius: 12,
                width: 350,
                isRequred: false,
                prefixIcon: Icons.card_giftcard,
                controller: ref,
                label: 'Referral Code',
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 350,
                label: 'Signup',
                onPressed: () async {
                  if (ref.text == '') {
                    if (password.text == confirmpassword.text) {
                      if (fname.text != '' ||
                          lname.text != '' ||
                          nickname.text != '' ||
                          email.text != '' ||
                          password.text != '') {
                        register(context);
                      } else {
                        showToast('All fields are required!');
                      }
                    } else {
                      showToast('Password do not match!');
                    }
                  } else {
                    DocumentSnapshot doc = await FirebaseFirestore.instance
                        .collection('Referals')
                        .doc(ref.text)
                        .get();

                    if (doc.exists) {
                      if (password.text == confirmpassword.text) {
                        if (fname.text != '' ||
                            lname.text != '' ||
                            nickname.text != '' ||
                            email.text != '' ||
                            password.text != '') {
                          await FirebaseFirestore.instance
                              .collection(doc['type'])
                              .doc(doc['uid'])
                              .update({'pts': FieldValue.increment(20)});
                          register(context);
                        } else {
                          showToast('All fields are required!');
                        }
                      } else {
                        showToast('Password do not match!');
                      }
                    } else {
                      showToast(
                          'Cannot proceed! Referral Code does not exist!');
                    }
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 150,
                    child: Divider(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextWidget(
                    text: 'or',
                    fontSize: 12,
                    color: blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    width: 150,
                    child: Divider(),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  googleLogin();
                },
                child: Container(
                  width: 325,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/googlelogo.png',
                          width: 25,
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        TextWidget(
                          text: 'Continue with Google',
                          fontSize: 14,
                          color: blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
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

  String generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  register(context) async {
    String key = generateUniqueKey(6);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      addUser(
          '${fname.text} ${lname.text}',
          email.text,
          nickname.text,
          imageURL,
          '${municipality!.name}, ${province!.name}',
          number.text,
          key);

      addReferal(key, 'Users');

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      showToast("Registered Successfully! Verification was sent to your email");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  inCustomer: true,
                )),
        (route) {
          return false;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  bool userExist = false;

  googleLogin() async {
    try {
      final googleSignInAccount = await googleSignIn.signIn();

      print(googleSignInAccount!.email);

      FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: googleSignInAccount.email)
          .get()
          .then(
        (value) {
          print(value);
        },
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: googleSignInAccount.email)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        for (var doc in querySnapshot.docs) {
          if (doc['email'] == googleSignInAccount.email) {
            setState(() {
              userExist = true;
            });
          }
        }
      }).whenComplete(
        () async {
          String key = generateUniqueKey(6);
          if (userExist) {
            Navigator.pop(context);

            showToast('Your google account is already used! Try logging in.');
          } else {
            // If the user doesn't exist, create a new user with Google credentials
            try {
              // Authenticate the GoogleSignInAccount and get the credentials
              final googleSignInAuth = await googleSignInAccount.authentication;
              final credential = GoogleAuthProvider.credential(
                accessToken: googleSignInAuth.accessToken,
                idToken: googleSignInAuth.idToken,
              );

              // Sign in to Firebase with the obtained credentials
              UserCredential userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);

              // Add the user to your Firestore or Realtime Database if needed
              addUser(
                  googleSignInAccount.displayName,
                  googleSignInAccount.email,
                  googleSignInAccount.displayName,
                  googleSignInAccount.photoUrl,
                  '',
                  '',
                  key);

              addReferal(key, 'Users');
            } catch (e) {
              print('Error: $e');
              // Handle the error accordingly
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const CustomerHomeScreen()),
              (route) {
                return false;
              },
            );
          }

// Navigate to the CustomerHomeScreen and remove all previous routes
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
