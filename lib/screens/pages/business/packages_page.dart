import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:juan_million/screens/auth/payment_screen.dart';
import 'package:juan_million/screens/pages/business/packages_payment_page.dart';
import 'package:juan_million/screens/pages/payment_selection_screen.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/button_widget.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';

class PackagePage extends StatefulWidget {
  String id;

  PackagePage({
    super.key,
    required this.id,
  });

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 60 : 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextWidget(
                      text: 'Choose Your Package',
                      fontSize: isWeb ? 24 : 18,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 60 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWeb)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              children: [
                                TextWidget(
                                  text: 'Step 3 of 3: Select Your Package',
                                  fontSize: 16,
                                  fontFamily: 'Medium',
                                  color: Colors.grey.shade600,
                                  align: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                TextWidget(
                                  text:
                                      'Choose the package that best fits your business needs',
                                  fontSize: 14,
                                  fontFamily: 'Regular',
                                  color: Colors.grey.shade600,
                                  align: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Packages')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }

                          final data = snapshot.requireData;

                          return isWeb
                              ? _buildWebPackageGrid(data)
                              : _buildMobilePackageList(data);
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebPackageGrid(QuerySnapshot data) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: List.generate(
            data.docs.length,
            (index) => _buildPackageCard(data.docs[index], true),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePackageList(QuerySnapshot data) {
    return Column(
      children: List.generate(
        data.docs.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildPackageCard(data.docs[index], false),
        ),
      ),
    );
  }

  Widget _buildPackageCard(DocumentSnapshot doc, bool isWeb) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: isWeb ? 350 : double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with logo
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withOpacity(0.1),
                    secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/Juan4All 2.png',
                  height: 80,
                ),
              ),
            ),
            // Package details
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // Price
                  TextWidget(
                    text: AppConstants.formatNumberWithPeso(doc['price']),
                    fontSize: 36,
                    color: primary,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 20),
                  // Features
                  _buildFeatureRow(
                    Icons.account_balance_wallet,
                    'Initial Load',
                    '${doc['wallet']}',
                  ),
                  const SizedBox(height: 15),
                  _buildFeatureRow(
                    Icons.receipt_long,
                    'Registration Fee',
                    '${doc['registrationFee']}',
                  ),
                  const SizedBox(height: 30),
                  // Select button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ButtonWidget(
                      radius: 12,
                      height: 50,
                      width: double.infinity,
                      fontSize: 16,
                      label: 'Select Package',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PackagesPaymentPage(
                              id: widget.id,
                              data: doc,
                            ),
                          ),
                        );
                      },
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: label,
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'Medium',
              ),
              TextWidget(
                text: value,
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Bold',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
