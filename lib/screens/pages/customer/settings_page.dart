import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/pages/customer/myqr_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CustomerSettingsPage extends StatefulWidget {
  const CustomerSettingsPage({super.key});

  @override
  State<CustomerSettingsPage> createState() => _CustomerSettingsPageState();
}

class _CustomerSettingsPageState extends State<CustomerSettingsPage> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();
  final number = TextEditingController();

  final password = TextEditingController();

  final pts = TextEditingController();

  // Track if controllers have been initialized
  bool _controllersInitialized = false;

  void _initializeControllers(dynamic data) {
    if (_controllersInitialized) return;

    String isNumber = data['email'].toString().split('@')[0];
    final nameParts = data['name'].toString().trim().split(RegExp(r'\s+'));

    fname.text = nameParts.isNotEmpty ? nameParts.first : '';
    lname.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    number.text = isPhoneNumber(isNumber) ? isNumber : data['number'];
    email.text = isPhoneNumber(isNumber) ? '' : data['email'];
    password.text = '*******';

    _controllersInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic data = snapshot.data;

            _initializeControllers(data);

            return isDesktop
                ? _buildDesktopLayout(data, context)
                : _buildMobileLayout(data, context);
          }),
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout(dynamic data, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Row(
        children: [
          // Sidebar with Profile
          Container(
            width: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primary, secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Profile Picture
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          uploadPicture('gallery');
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(data['pic']),
                            onBackgroundImageError: (exception, stackTrace) {},
                            child: data['pic'] == null ||
                                    data['pic'].toString().isEmpty
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient:
                                LinearGradient(colors: [primary, secondary]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextWidget(
                    text: data['name'],
                    fontSize: 26,
                    fontFamily: 'Bold',
                    color: Colors.white,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: data['email'],
                    fontSize: 15,
                    fontFamily: 'Medium',
                    color: Colors.white.withOpacity(0.9),
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Menu Items
                  _buildDesktopMenuItem(
                    Icons.person_rounded,
                    'Profile Settings',
                    true,
                    () {},
                  ),
                  _buildDesktopMenuItem(
                    Icons.qr_code_rounded,
                    'My QR Code',
                    false,
                    () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MyQRPage()));
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        leading: const Icon(Icons.logout_rounded,
                            color: Colors.white),
                        title: TextWidget(
                          text: 'Logout',
                          fontSize: 15,
                          fontFamily: 'Medium',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Profile Settings',
                        fontSize: 32,
                        fontFamily: 'Bold',
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      TextWidget(
                        text: 'Update your personal information',
                        fontSize: 16,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 40),
                      _buildDesktopForm(data),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMenuItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 15),
            TextWidget(
              text: label,
              fontSize: 15,
              fontFamily: isActive ? 'Bold' : 'Medium',
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopForm(dynamic data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFormField('First Name', fname, Icons.person_outline),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFormField('Last Name', lname, Icons.person_outline),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildFormField('Contact Number', number, Icons.phone),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFormField('Email', email, Icons.email_outlined,
                  enabled: false),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildFormField('Password', password, Icons.lock_outline,
                  enabled: false, obscure: true),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Referals')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  dynamic referralData = snapshot.data;
                  return _buildFormField(
                    'Referral Code',
                    TextEditingController(
                        text: '${referralData['ref']} (Referral Code)'),
                    Icons.card_giftcard,
                    enabled: false,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
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
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(data.id)
                    .update({
                  'name': '${fname.text} ${lname.text}',
                  'number': number.text,
                });
                showToast('Profile updated!', context: context);
              },
              child: Center(
                child: TextWidget(
                  text: 'Update Profile',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
      String label, TextEditingController controller, IconData icon,
      {bool enabled = true, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFieldWidget(
        isEnabled: enabled,
        showEye: obscure,
        isObscure: obscure,
        fontStyle: FontStyle.normal,
        hint: label,
        borderColor: Colors.transparent,
        radius: 15,
        width: double.infinity,
        isRequred: false,
        prefixIcon: icon,
        controller: controller,
        label: label,
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(dynamic data, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Gradient Header with Profile
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Back button row
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
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Profile picture with edit button
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            uploadPicture('gallery');
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(data['pic']),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle error
                              },
                              child: data['pic'] == null ||
                                      data['pic'].toString().isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, secondary],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // User info
                    TextWidget(
                      text: data['name'],
                      fontSize: 24,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      text: data['email'],
                      fontSize: 15,
                      fontFamily: 'Medium',
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          // Form section with improved styling
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                TextWidget(
                  text: 'Personal Information',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
                const SizedBox(height: 20),

                // First name field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFieldWidget(
                    fontStyle: FontStyle.normal,
                    hint: 'First Name',
                    borderColor: Colors.transparent,
                    radius: 15,
                    width: double.infinity,
                    isRequred: false,
                    prefixIcon: Icons.person_3_outlined,
                    controller: fname,
                    label: 'First Name',
                  ),
                ),
                const SizedBox(height: 20),

                // Last name field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFieldWidget(
                    fontStyle: FontStyle.normal,
                    hint: 'Last Name',
                    borderColor: Colors.transparent,
                    radius: 15,
                    width: double.infinity,
                    isRequred: false,
                    prefixIcon: Icons.person_3_outlined,
                    controller: lname,
                    label: 'Last Name',
                  ),
                ),
                const SizedBox(height: 20),

                // Contact number field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFieldWidget(
                    inputType: TextInputType.number,
                    fontStyle: FontStyle.normal,
                    hint: 'Contact Number',
                    borderColor: Colors.transparent,
                    radius: 15,
                    width: double.infinity,
                    isRequred: false,
                    controller: number,
                    prefixIcon: Icons.phone,
                    label: 'Contact Number',
                  ),
                ),
                const SizedBox(height: 20),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFieldWidget(
                    isEnabled: false,
                    fontStyle: FontStyle.normal,
                    hint: 'Email',
                    borderColor: Colors.transparent,
                    radius: 15,
                    width: double.infinity,
                    isRequred: false,
                    controller: email,
                    prefixIcon: Icons.email_outlined,
                    label: 'Email',
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFieldWidget(
                    isEnabled: false,
                    showEye: true,
                    isObscure: true,
                    prefixIcon: Icons.lock_open_outlined,
                    fontStyle: FontStyle.normal,
                    hint: 'Password',
                    borderColor: Colors.transparent,
                    radius: 15,
                    width: double.infinity,
                    isRequred: false,
                    controller: password,
                    label: 'Password',
                  ),
                ),
                const SizedBox(height: 20),

                // Referral code field
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Referals')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Loading'));
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      dynamic referralData = snapshot.data;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFieldWidget(
                          isEnabled: false,
                          fontStyle: FontStyle.normal,
                          hint: 'Referral Code',
                          borderColor: Colors.transparent,
                          radius: 15,
                          width: double.infinity,
                          isRequred: false,
                          prefixIcon: Icons.card_giftcard_sharp,
                          controller: TextEditingController(
                            text: '${referralData['ref']} (Referral Code)',
                          ),
                          label: 'Referral Code',
                        ),
                      );
                    }),
                const SizedBox(height: 30),

                // Modern Update button with gradient
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
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(data.id)
                            .update({
                          'name': '${fname.text} ${lname.text}',
                          'number': number.text,
                        });
                        showToast('Profile updated!', context: context);
                      },
                      child: Center(
                        child: TextWidget(
                          text: 'Update Profile',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // More options section
                TextWidget(
                  text: 'More Options',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
                const SizedBox(height: 15),

                // My QR Code option
                Container(
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
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MyQRPage()));
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code,
                        color: Colors.blue,
                      ),
                    ),
                    title: TextWidget(
                      text: 'My QR Code',
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: 'Medium',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Logout option
                Container(
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
                  child: ListTile(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text(
                                  'Logout Confirmation',
                                  style: TextStyle(
                                      fontFamily: 'Bold',
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                  style: TextStyle(fontFamily: 'Regular'),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          fontFamily: 'Medium',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LandingScreen()));
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'Medium',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ));
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                    ),
                    title: TextWidget(
                      text: 'Logout',
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: 'Medium',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Logout Confirmation',
          style: TextStyle(fontFamily: 'Bold', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Regular'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cancel',
              style:
                  TextStyle(fontFamily: 'Medium', fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LandingScreen()));
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Medium',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'pic': imageURL,
        });

        setState(() {});

        Navigator.of(context).pop();
        showToast('Image uploaded!', context: context);
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

  bool isPhoneNumber(String input) {
    // Define a regex pattern that matches Philippine phone number formats
    RegExp phoneRegex = RegExp(
      r'^(09|\+639)\d{9}$',
      caseSensitive: false,
      multiLine: false,
    );

    // Use RegExp's hasMatch method to check if the input matches the pattern
    return phoneRegex.hasMatch(input);
  }
}
