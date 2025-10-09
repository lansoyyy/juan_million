import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRPage extends StatefulWidget {
  bool? isPoints;

  MyQRPage({
    super.key,
    this.isPoints = false,
  });

  @override
  State<MyQRPage> createState() => _MyQRPageState();
}

class _MyQRPageState extends State<MyQRPage> {
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          dynamic mydata = snapshot.data;

          return Container(
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
            child: SafeArea(
              child: Column(
                children: [
                  // Modern Header
                  Padding(
                    padding: EdgeInsets.all(isDesktop ? 30 : 20),
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
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'My QR Code',
                                fontSize: isDesktop ? 28 : 24,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: widget.isPoints!
                                    ? 'Scan to receive points'
                                    : 'Scan to receive payment',
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 100 : 25,
                            vertical: 20,
                          ),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 500 : double.infinity,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Profile Info Card
                                Container(
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // User Avatar
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: isDesktop ? 60 : 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextWidget(
                                        text: mydata['name'],
                                        fontSize: isDesktop ? 26 : 22,
                                        color: Colors.white,
                                        fontFamily: 'Bold',
                                        align: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextWidget(
                                          text: widget.isPoints!
                                              ? 'Points Account'
                                              : 'Wallet Account',
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontFamily: 'Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 35),

                                // QR Code Card
                                Container(
                                  padding: EdgeInsets.all(isDesktop ? 40 : 30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // QR Code
                                      Container(
                                        padding:
                                            EdgeInsets.all(isDesktop ? 25 : 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: primary.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: QrImageView(
                                          data: mydata.id,
                                          size: isDesktop ? 280 : 240,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 25),

                                      // Balance Display
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25,
                                          vertical: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primary.withOpacity(0.1),
                                              secondary.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            TextWidget(
                                              text: widget.isPoints!
                                                  ? 'Points Balance'
                                                  : 'Wallet Balance',
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontFamily: 'Medium',
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: widget.isPoints!
                                                      ? '${mydata['pts'].toString()}'
                                                      : '₱${mydata['wallet'].toString()}',
                                                  fontSize: isDesktop ? 42 : 36,
                                                  color: primary,
                                                  fontFamily: 'Bold',
                                                ),
                                                if (widget.isPoints!) ...[
                                                  const SizedBox(width: 8),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: TextWidget(
                                                      text: 'pts',
                                                      fontSize: 18,
                                                      color: primary
                                                          .withOpacity(0.7),
                                                      fontFamily: 'Bold',
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Instructions
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextWidget(
                                                text: widget.isPoints!
                                                    ? 'Show this QR code to merchants to receive points'
                                                    : 'Show this QR code to receive payments',
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                fontFamily: 'Regular',
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Logo
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Image.asset(
                                    'assets/images/Juan4All 2.png',
                                    height: isDesktop ? 80 : 60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
