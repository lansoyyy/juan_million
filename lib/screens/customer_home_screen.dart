import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/screens/pages/customer/affiliates_locator_page.dart';
import 'package:juan_million/screens/pages/customer/inventory_page.dart';
import 'package:juan_million/screens/pages/customer/myqr_page.dart';
import 'package:juan_million/screens/pages/customer/notif_page.dart';
import 'package:juan_million/screens/pages/customer/points_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanned_page.dart';
import 'package:juan_million/screens/pages/customer/qr_scanner_screen.dart';
import 'package:juan_million/screens/pages/customer/settings_page.dart';
import 'package:juan_million/screens/pages/customer/wallet_page.dart';
import 'package:juan_million/services/add_slots.dart';
import 'package:juan_million/utlis/app_constants.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String qrCode = 'Unknown';
  String store = '';
  String pts = '';
  late final String _currentUserId;
  late final Stream<DocumentSnapshot> _userData;

  Future<void> scanQRCode() async {
    try {
      // Navigate to a new screen for QR scanning
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QRScannerScreen(),
        ),
      );

      if (result == null) {
        // User cancelled the scan
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        qrCode = result;
      });

      final pointsRef =
          FirebaseFirestore.instance.collection('Points').doc(result);
      final pointsSnap = await pointsRef.get();
      if (!pointsSnap.exists) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final Map<String, dynamic>? data = pointsSnap.data();
      if (data == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final bool alreadyScanned = data['scanned'] == true;
      if (alreadyScanned) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('This QR code was already claimed', context: context);
        return;
      }

      final dynamic rawPts = data['pts'];
      final int ptsValue = rawPts is num ? rawPts.toInt() : 0;
      final String businessId = data['uid']?.toString() ?? '';
      if (ptsValue <= 0 || businessId.isEmpty) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        showToast('Invalid QR code', context: context);
        return;
      }

      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(_currentUserId);
      final businessRef =
          FirebaseFirestore.instance.collection('Business').doc(businessId);
      final communityRef = FirebaseFirestore.instance
          .collection('Community Wallet')
          .doc('wallet');

      final batch = FirebaseFirestore.instance.batch();
      batch.update(userRef, {
        'pts': FieldValue.increment(ptsValue),
      });
      batch.update(businessRef, {
        'pts': FieldValue.increment(-ptsValue),
      });
      batch.update(pointsRef, {
        'scanned': true,
        'scannedId': _currentUserId,
      });
      batch.update(communityRef, {
        'pts': FieldValue.increment(ptsValue),
      });
      await batch.commit();

      setState(() {
        pts = ptsValue.toString();
        store = businessId;
      });

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QRScannedPage(
                pts: pts,
                store: store,
              )));
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showToast('Failed to scan QR code', context: context);
    } catch (_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showToast('Scan failed. Please try again.', context: context);
    }
  }

  void checkPoints(int limit) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot['pts'].toInt() >= limit) {
        await FirebaseFirestore.instance
            .collection('Slots')
            .where('uid', isEqualTo: _currentUserId)
            .where('dateTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day)))
            .where('dateTime',
                isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day + 1)
                    .subtract(const Duration(seconds: 1))))
            .get()
            .then((snapshot) {
          int slotsFromPoints = documentSnapshot['pts'].toInt() ~/ limit;
          int currentSlots = snapshot.docs.length;
          int slotsLeft = 5 - currentSlots;

          if (slotsFromPoints > slotsLeft) {
            FirebaseFirestore.instance
                .collection('Users')
                .doc(_currentUserId)
                .update({
              'pts': FieldValue.increment(-slotsLeft * limit),
            });
            for (int i = 0; i < slotsLeft; i++) {
              addSlots();
            }
          } else {
            FirebaseFirestore.instance
                .collection('Users')
                .doc(_currentUserId)
                .update({
              'pts': FieldValue.increment(-slotsFromPoints * limit),
            });
            for (int i = 0; i < slotsFromPoints; i++) {
              addSlots();
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUserId)
        .snapshots();
    checkPoints(150);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: scanQRCode,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userData,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          dynamic data = snapshot.data;

          return isDesktop
              ? _buildDesktopLayout(data, context)
              : _buildMobileLayout(data, context);
        },
      ),
    );
  }

  // Desktop Layout with Sidebar
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
          // Modern Sidebar
          Container(
            width: 280,
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
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/Juan4All 2.png',
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextWidget(
                    text: 'Juan 4 All',
                    fontSize: 24,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  const SizedBox(height: 40),
                  // Menu Items
                  _buildSidebarItem(
                    icon: Icons.home_rounded,
                    label: 'Dashboard',
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildSidebarItem(
                    icon: Icons.business_rounded,
                    label: 'Affiliates',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AffiliateLocatorPage()));
                    },
                  ),
                  _buildSidebarItem(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CustomerNotifPage()));
                    },
                  ),
                  _buildSidebarItem(
                    icon: Icons.qr_code_rounded,
                    label: 'My QR Code',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyQRPage(isPoints: true)));
                    },
                  ),
                  _buildSidebarItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CustomerSettingsPage()));
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          TextWidget(
                            text: 'Need Help?',
                            fontSize: 14,
                            fontFamily: 'Medium',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Hello ka-Juan! 👋',
                              fontSize: 32,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 8),
                            TextWidget(
                              text: 'Welcome back to your dashboard',
                              fontSize: 16,
                              fontFamily: 'Regular',
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerHomeScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          iconSize: 28,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Wallet Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDesktopWalletCard(
                            context,
                            'Total Points',
                            '${data['pts'].toInt()}',
                            Icons.stars_rounded,
                            [primary, secondary],
                            () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerPointsPage()));
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDesktopWalletCard(
                            context,
                            'E-Wallet',
                            AppConstants.formatNumberWithPeso(data['wallet']),
                            Icons.account_balance_wallet_rounded,
                            [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
                            () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerWalletPage()));
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Slots')
                                .where('uid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return _buildDesktopWalletCard(
                                  context,
                                  'Community Wallet',
                                  '0',
                                  Icons.group_rounded,
                                  [
                                    const Color(0xFFf093fb),
                                    const Color(0xFFf5576c)
                                  ],
                                  () {},
                                );
                              }
                              return _buildDesktopWalletCard(
                                context,
                                'Community Wallet',
                                '${snapshot.data!.docs.length}',
                                Icons.group_rounded,
                                [
                                  const Color(0xFFf093fb),
                                  const Color(0xFFf5576c)
                                ],
                                () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerInventoryPage()));
                                },
                                subtitle: 'Your Slots',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Recent Activity
                    _buildDesktopRecentActivity(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
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

  Widget _buildDesktopWalletCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: gradientColors[1].withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.7), size: 18),
                ],
              ),
              const SizedBox(height: 25),
              TextWidget(
                text: title,
                fontSize: 14,
                fontFamily: 'Medium',
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: value,
                fontSize: 36,
                fontFamily: 'Bold',
                color: Colors.white,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                TextWidget(
                  text: subtitle,
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            TextWidget(
              text: 'Recent Activity',
              fontSize: 24,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ],
        ),
        const SizedBox(height: 25),
        StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _getCombinedActivityStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      TextWidget(
                        text: 'No Recent Activity',
                        fontSize: 18,
                        fontFamily: 'Medium',
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final doc = data[index];
                final docData = doc.data() as Map<String, dynamic>;
                final dynamic rawPts = docData['pts'];
                final double points = rawPts is num ? rawPts.toDouble() : 0.0;
                final dynamic rawDateTime = docData['dateTime'];
                final DateTime? dateTime =
                    rawDateTime is Timestamp ? rawDateTime.toDate() : null;
                final String transactionType =
                    docData['type']?.toString() ?? '';
                final bool isWalletTransaction =
                    transactionType.contains('Transfer') ||
                        transactionType.contains('Reload') ||
                        transactionType.contains('Purchase');

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Business')
                      .doc(docData['uid'])
                      .snapshots(),
                  builder: (context, businessSnapshot) {
                    String sourceName = 'Juan Million';
                    if (businessSnapshot.hasData) {
                      final snap = businessSnapshot.data!;
                      if (snap.exists) {
                        final b = snap.data();
                        if (b is Map && b['name'] != null) {
                          sourceName = b['name'].toString();
                        }
                      }
                    }
                    return Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: primary.withOpacity(0.1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isWalletTransaction
                                        ? Colors.blue.withOpacity(0.1)
                                        : primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextWidget(
                                    text: sourceName,
                                    fontSize: 12,
                                    fontFamily: 'Bold',
                                    color: isWalletTransaction
                                        ? Colors.blue
                                        : primary,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                  isWalletTransaction
                                      ? Icons.account_balance_wallet_rounded
                                      : Icons.star_rounded,
                                  color: isWalletTransaction
                                      ? Colors.blue
                                      : Colors.amber,
                                  size: 20),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextWidget(
                                text: points.toStringAsFixed(0),
                                fontSize: 32,
                                fontFamily: 'Bold',
                                color: primary,
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: TextWidget(
                                  text: 'pts',
                                  fontSize: 14,
                                  fontFamily: 'Bold',
                                  color: primary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          TextWidget(
                            text: dateTime != null
                                ? DateFormat.yMMMd().add_jm().format(dateTime)
                                : '-',
                            fontSize: 11,
                            fontFamily: 'Regular',
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Stream<List<QueryDocumentSnapshot>> _getCombinedActivityStream() async* {
    final pointsQuery = FirebaseFirestore.instance
        .collection('Points')
        .where('scannedId', isEqualTo: _currentUserId)
        .limit(10);

    final walletsQuery = FirebaseFirestore.instance
        .collection('Wallets')
        .where('uid', isEqualTo: _currentUserId)
        .limit(10);

    await for (final pointsSnap in pointsQuery.snapshots()) {
      final walletsSnap = await walletsQuery.get();

      final combined = <QueryDocumentSnapshot>[];
      combined.addAll(pointsSnap.docs);
      combined.addAll(walletsSnap.docs);

      // Sort by dateTime descending
      combined.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTime = aData['dateTime'] is Timestamp
            ? (aData['dateTime'] as Timestamp).toDate()
            : DateTime(2000);
        final bTime = bData['dateTime'] is Timestamp
            ? (bData['dateTime'] as Timestamp).toDate()
            : DateTime(2000);
        return bTime.compareTo(aTime);
      });

      yield combined.take(6).toList();
    }
  }

  // Mobile Layout
  Widget _buildMobileLayout(dynamic data, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Modern Curved Header
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
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Hello ka-Juan! 👋',
                                fontSize: 28,
                                fontFamily: 'Bold',
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              TextWidget(
                                text: DateFormat('EEEE, MMMM d')
                                    .format(DateTime.now()),
                                fontSize: 14,
                                fontFamily: 'Regular',
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildHeaderAction(
                              Icons.qr_code_rounded,
                              () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        MyQRPage(isPoints: true)));
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildHeaderAction(
                              Icons.refresh_rounded,
                              () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerHomeScreen()),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(
                          Icons.business_rounded,
                          'Affiliates',
                          () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const AffiliateLocatorPage()));
                          },
                        ),
                        _buildQuickAction(
                          Icons.notifications_rounded,
                          'Notifications',
                          () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const CustomerNotifPage()));
                          },
                        ),
                        _buildQuickAction(
                          Icons.settings_rounded,
                          'Settings',
                          () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const CustomerSettingsPage()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Wallet Cards
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                _buildMobileWalletCard(
                  'Total Points',
                  '${data['pts'].toInt()}',
                  Icons.stars_rounded,
                  [primary, secondary],
                  () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CustomerPointsPage()));
                  },
                ),
                const SizedBox(height: 20),
                _buildMobileWalletCard(
                  'E-Wallet',
                  AppConstants.formatNumberWithPeso(data['wallet']),
                  Icons.account_balance_wallet_rounded,
                  [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
                  () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CustomerWalletPage()));
                  },
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Slots')
                      .where('uid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildMobileWalletCard(
                        'Community Wallet',
                        '0',
                        Icons.group_rounded,
                        [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                        () {},
                        subtitle: 'Your Slots',
                      );
                    }
                    return _buildMobileWalletCard(
                      'Community Wallet',
                      '${snapshot.data!.docs.length}',
                      Icons.group_rounded,
                      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                      () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const CustomerInventoryPage()));
                      },
                      subtitle: 'Your Slots',
                    );
                  },
                ),
              ],
            ),
          ),
          // Recent Activity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primary, secondary]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    TextWidget(
                      text: 'Recent Activity',
                      fontSize: 22,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMobileRecentActivity(context),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          TextWidget(
            text: label,
            fontSize: 13,
            fontFamily: 'Medium',
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileWalletCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: title,
                    fontSize: 14,
                    fontFamily: 'Medium',
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: value,
                    fontSize: 32,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    TextWidget(
                      text: subtitle,
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRecentActivity(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getCombinedActivityStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'No Recent Activity',
                    fontSize: 16,
                    fontFamily: 'Medium',
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final docData = doc.data() as Map<String, dynamic>;
              final dynamic rawPts = docData['pts'];
              final double points = rawPts is num ? rawPts.toDouble() : 0.0;
              final dynamic rawDateTime = docData['dateTime'];
              final DateTime? dateTime =
                  rawDateTime is Timestamp ? rawDateTime.toDate() : null;
              final String transactionType = docData['type']?.toString() ?? '';
              final bool isWalletTransaction =
                  transactionType.contains('Transfer') ||
                      transactionType.contains('Reload') ||
                      transactionType.contains('Purchase');

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Business')
                    .doc(docData['uid'])
                    .snapshots(),
                builder: (context, businessSnapshot) {
                  String sourceName = 'Juan Million';
                  if (businessSnapshot.hasData) {
                    final snap = businessSnapshot.data!;
                    if (snap.exists) {
                      final b = snap.data();
                      if (b is Map && b['name'] != null) {
                        sourceName = b['name'].toString();
                      }
                    }
                  }
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: primary.withOpacity(0.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isWalletTransaction
                                      ? Colors.blue.withOpacity(0.1)
                                      : primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextWidget(
                                  text: sourceName,
                                  fontSize: 11,
                                  fontFamily: 'Bold',
                                  color: isWalletTransaction
                                      ? Colors.blue
                                      : primary,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                                isWalletTransaction
                                    ? Icons.account_balance_wallet_rounded
                                    : Icons.star_rounded,
                                color: isWalletTransaction
                                    ? Colors.blue
                                    : Colors.amber,
                                size: 18),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextWidget(
                              text: points.toStringAsFixed(0),
                              fontSize: 36,
                              fontFamily: 'Bold',
                              color: primary,
                            ),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: TextWidget(
                                text: 'pts',
                                fontSize: 14,
                                fontFamily: 'Bold',
                                color: primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        TextWidget(
                          text: dateTime != null
                              ? DateFormat.yMMMd().add_jm().format(dateTime)
                              : '-',
                          fontSize: 11,
                          fontFamily: 'Regular',
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
