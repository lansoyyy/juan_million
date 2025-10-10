import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final searchController = TextEditingController();
  String nameSearched = '';

  @override
  Widget build(BuildContext context) {
    // Check if desktop
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.white : Colors.lightBlue,
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSidebar(context),
                Expanded(
                  child: _buildContent(context),
                ),
              ],
            )
          : _buildContent(context),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
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
                    icon: Icons.history_rounded,
                    label: 'Transactions',
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                Icon(icon, color: Colors.white, size: 22),
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

  Widget _buildContent(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Points')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('scanned', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              )),
            );
          }

          final data = snapshot.requireData;
          return Container(
            decoration: isDesktop
                ? null
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlue, Colors.blue.shade700],
                    ),
                  ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop)
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                            )),
                      ),
                    const SizedBox(height: 20),
                    // Modern Stats Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDesktop
                                ? [Colors.blue.shade50, Colors.white]
                                : [Colors.white, Colors.blue.shade50],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: blue,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextWidget(
                              text: 'Transaction History',
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontFamily: 'Medium',
                            ),
                            const SizedBox(height: 10),
                            TextWidget(
                              text: data.docs.length.toString(),
                              fontFamily: 'Bold',
                              fontSize: 64,
                              color: blue,
                            ),
                            const SizedBox(height: 5),
                            TextWidget(
                              text: 'Total Customers',
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Medium',
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: blue, size: 16),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: DateFormat.yMMMd().format(DateTime.now()),
                                    fontSize: 12,
                                    color: blue,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Customer List Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: 'Customer Details',
                                fontSize: 20,
                                color: isDesktop ? Colors.black87 : Colors.white,
                                fontFamily: 'Bold',
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDesktop
                                      ? blue.withOpacity(0.1)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: isDesktop ? blue : Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    TextWidget(
                                      text: '${data.docs.length}',
                                      fontSize: 12,
                                      color: isDesktop ? blue : Colors.white,
                                      fontFamily: 'Bold',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Desktop Table View
                          if (isDesktop)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Table Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: blue.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextWidget(
                                            text: 'Customer Name',
                                            fontSize: 13,
                                            color: Colors.black87,
                                            fontFamily: 'Bold',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: TextWidget(
                                              text: 'Points Balance',
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontFamily: 'Bold',
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: TextWidget(
                                              text: 'Points Redeemed',
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontFamily: 'Bold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Table Body
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: data.docs.length,
                                    separatorBuilder: (context, index) => Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                    itemBuilder: (context, index) {
                                      return data.docs[index]['scannedId'] == ''
                                          ? const SizedBox()
                                          : StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(data.docs[index]['scannedId'])
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot<DocumentSnapshot>
                                                      snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const SizedBox();
                                                } else if (snapshot.hasError) {
                                                  return const SizedBox();
                                                } else if (snapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const SizedBox();
                                                }
                                                dynamic userData = snapshot.data;

                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 16),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  blue.withOpacity(
                                                                      0.1),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: blue,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: TextWidget(
                                                                text: userData[
                                                                    'name'],
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    'Medium',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.green
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: TextWidget(
                                                              text: userData[
                                                                      'pts']
                                                                  .toString(),
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.green,
                                                              fontFamily: 'Bold',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orange
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: TextWidget(
                                                              text: data.docs[
                                                                      index]['pts']
                                                                  .toString(),
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.orange,
                                                              fontFamily: 'Bold',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          // Mobile Card View
                          if (!isDesktop)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.docs.length,
                              itemBuilder: (context, index) {
                                return data.docs[index]['scannedId'] == ''
                                    ? const SizedBox()
                                    : StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(data.docs[index]['scannedId'])
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<DocumentSnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox();
                                          } else if (snapshot.hasError) {
                                            return const SizedBox();
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox();
                                          }
                                          dynamic userData = snapshot.data;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            blue.withOpacity(0.1),
                                                        child: Icon(
                                                          Icons.person,
                                                          color: blue,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: TextWidget(
                                                          text: userData['name'],
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Divider(height: 1),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextWidget(
                                                            text:
                                                                'Points Balance',
                                                            fontSize: 11,
                                                            color:
                                                                Colors.grey.shade600,
                                                            fontFamily: 'Medium',
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.green
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: TextWidget(
                                                              text: userData[
                                                                      'pts']
                                                                  .toString(),
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.green,
                                                              fontFamily: 'Bold',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextWidget(
                                                            text:
                                                                'Points Redeemed',
                                                            fontSize: 11,
                                                            color:
                                                                Colors.grey.shade600,
                                                            fontFamily: 'Medium',
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orange
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: TextWidget(
                                                              text: data.docs[
                                                                      index]['pts']
                                                                  .toString(),
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.orange,
                                                              fontFamily: 'Bold',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                              },
                            ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
