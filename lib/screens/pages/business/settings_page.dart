import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/pages/business/myqr_page.dart';
import 'package:juan_million/screens/pages/business/profile_page.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/textfield_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final name = TextEditingController();
  final email = TextEditingController();

  final password = TextEditingController();
  final newpassword = TextEditingController();

  final pts = TextEditingController();

  Future<void> reauthenticateUser(
      String email, String password, dynamic data) async {
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

    try {
      await user.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('Business')
          .doc(data.id)
          .update({
        'name': name.text,
        'ptsconversion': int.parse(pts.text)
        // 'ptsconversion': double.parse(pts.text),
      });
      showToast('Business information updated!');
    } on FirebaseAuthException catch (e) {
      showToast('Unauthorized to access this feature!');
      print("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Business')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    // Check if desktop
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
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

            name.text = data['name'].toString();
            email.text = data['email'].toString();
            pts.text = data['ptsconversion'].toStringAsFixed(0);

            password.text = '*******';

            return isDesktop
                ? _buildDesktopLayout(data, context)
                : _buildMobileLayout(data, context);
          }),
    );
  }

  // Desktop Layout with Sidebar
  Widget _buildDesktopLayout(dynamic data, BuildContext context) {
    return Row(
      children: [
        // Sidebar (reuse from business home)
        Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [blue, Colors.blue.shade900],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Juan Million',
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: 'Business Dashboard',
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildSidebarItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        isActive: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: data['name'] ?? 'Business User',
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Medium',
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: 'Business Account',
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main Content
        Expanded(
          child: _buildMobileLayout(data, context),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 16),
                TextWidget(
                  text: label,
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: isActive ? 'Bold' : 'Medium',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(dynamic data, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [blue, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextWidget(
                        text: 'Settings',
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: 'Business Settings',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Medium',
                                ),
                                const SizedBox(height: 5),
                                TextWidget(
                                  text:
                                      'Manage your business information and preferences',
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontFamily: 'Regular',
                                  align: TextAlign.start,
                                  maxLines: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextFieldWidget(
                        fontStyle: FontStyle.normal,
                        hint: 'Business Name',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        prefixIcon: Icons.person_3_outlined,
                        controller: name,
                        label: 'Business Name',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextFieldWidget(
                        isEnabled: false,
                        fontStyle: FontStyle.normal,
                        hint: 'Business Email',
                        borderColor: blue,
                        radius: 12,
                        width: 350,
                        isRequred: false,
                        controller: email,
                        prefixIcon: Icons.email_outlined,
                        label: 'Business Email',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextFieldWidget(
                        isEnabled: false,
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
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextFieldWidget(
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
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                      dynamic data = snapshot.data;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextFieldWidget(
                              isEnabled: false,
                              fontStyle: FontStyle.normal,
                              hint: 'Referral Code',
                              borderColor: blue,
                              radius: 12,
                              width: 350,
                              isRequred: false,
                              prefixIcon: Icons.card_giftcard_sharp,
                              controller: TextEditingController(
                                text: '${data['ref']} (Referral Code)',
                              ),
                              label: 'Referral Code',
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ButtonWidget(
                width: 350,
                label: 'Save Changes',
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text: 'Confirm Changes',
                                    fontSize: 18,
                                    fontFamily: 'Bold',
                                    color: Colors.black87,
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextWidget(
                                  text:
                                      'Please enter your password to confirm these changes',
                                  fontSize: 14,
                                  maxLines: 3,
                                  align: TextAlign.center,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFieldWidget(
                                showEye: true,
                                isObscure: true,
                                fontStyle: FontStyle.normal,
                                hint: 'Enter Password',
                                borderColor: blue,
                                radius: 12,
                                width: 350,
                                height: 75,
                                prefixIcon: Icons.lock,
                                isRequred: false,
                                controller: newpassword,
                                label: 'Enter Password',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ButtonWidget(
                                label: 'Confirm & Save',
                                onPressed: () {
                                  reauthenticateUser(
                                      data['email'], newpassword.text, data);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 5,
                      decoration: BoxDecoration(
                        color: blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextWidget(
                      text: 'More Options',
                      color: blue,
                      fontSize: 16,
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfikePage(
                                  data: data,
                                )));
                      },
                      tileColor: Colors.white,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.person_2_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      title: TextWidget(
                        text: 'My Account',
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Medium',
                      ),
                      trailing: const AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyQRBusinessPage()));
                      },
                      tileColor: Colors.white,
                      leading: Container(
                        decoration: BoxDecoration(
                          color: blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.qr_code,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      title: TextWidget(
                        text: 'My QR Code',
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Medium',
                      ),
                      trailing: const AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.logout,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextWidget(
                                        text: 'Logout Confirmation',
                                        fontSize: 18,
                                        fontFamily: 'Bold',
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(height: 10),
                                      TextWidget(
                                        text:
                                            'Are you sure you want to logout?',
                                        fontSize: 14,
                                        fontFamily: 'Regular',
                                        color: Colors.grey,
                                        align: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: TextWidget(
                                              text: 'Cancel',
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontFamily: 'Medium',
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LandingScreen()));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: TextWidget(
                                              text: 'Logout',
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontFamily: 'Bold',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                    },
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        title: TextWidget(
                          text: 'Logout',
                          fontSize: 16,
                          color: Colors.black87,
                          fontFamily: 'Medium',
                        ),
                        trailing: const AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
