import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CustomerNotifPage extends StatefulWidget {
  const CustomerNotifPage({super.key});

  @override
  State<CustomerNotifPage> createState() => _CustomerNotifPageState();
}

class _CustomerNotifPageState extends State<CustomerNotifPage> {
  String _filterType = 'all'; // all, today, week, month

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Modern Gradient Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
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
                            text: 'Notifications',
                            fontSize: isDesktop ? 28 : 24,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: 'Stay updated with your activities',
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
            ),
          ),
          // Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Points')
                    .where('uid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print('error');
                    return const Center(child: Text('Error'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.requireData;

                  // Filter notifications based on selected filter
                  List<QueryDocumentSnapshot> filteredDocs = [];
                  DateTime now = DateTime.now();

                  if (_filterType == 'all') {
                    filteredDocs = data.docs.toList();
                  } else if (_filterType == 'today') {
                    filteredDocs = data.docs.where((doc) {
                      final dynamic rawDateTime = doc['dateTime'];
                      if (rawDateTime is! Timestamp) return false;
                      DateTime docDate = rawDateTime.toDate();
                      return docDate.day == now.day &&
                          docDate.month == now.month &&
                          docDate.year == now.year;
                    }).toList();
                  } else if (_filterType == 'week') {
                    filteredDocs = data.docs.where((doc) {
                      final dynamic rawDateTime = doc['dateTime'];
                      if (rawDateTime is! Timestamp) return false;
                      DateTime docDate = rawDateTime.toDate();
                      return now.difference(docDate).inDays <= 7;
                    }).toList();
                  } else if (_filterType == 'month') {
                    filteredDocs = data.docs.where((doc) {
                      final dynamic rawDateTime = doc['dateTime'];
                      if (rawDateTime is! Timestamp) return false;
                      DateTime docDate = rawDateTime.toDate();
                      return docDate.month == now.month &&
                          docDate.year == now.year;
                    }).toList();
                  }

                  filteredDocs.sort((a, b) {
                    final dynamic aDateTime = a['dateTime'];
                    final dynamic bDateTime = b['dateTime'];
                    final int aMs = aDateTime is Timestamp
                        ? aDateTime.millisecondsSinceEpoch
                        : 0;
                    final int bMs = bDateTime is Timestamp
                        ? bDateTime.millisecondsSinceEpoch
                        : 0;
                    return bMs.compareTo(aMs);
                  });

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          TextWidget(
                            text: 'No notifications',
                            fontSize: 18,
                            fontFamily: 'Medium',
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 10),
                          TextWidget(
                            text: _filterType == 'all'
                                ? 'You have no notifications yet'
                                : 'No notifications for this period',
                            fontSize: 14,
                            fontFamily: 'Regular',
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(isDesktop ? 30 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Modern Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                  'All', 'all', Icons.notifications_rounded),
                              const SizedBox(width: 12),
                              _buildFilterChip(
                                  'Today', 'today', Icons.today_rounded),
                              const SizedBox(width: 12),
                              _buildFilterChip('This Week', 'week',
                                  Icons.date_range_rounded),
                              const SizedBox(width: 12),
                              _buildFilterChip('This Month', 'month',
                                  Icons.calendar_month_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Notifications list
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final dynamic rawPts = doc['pts'];
                              final double points =
                                  rawPts is num ? rawPts.toDouble() : 0.0;
                              final dynamic rawDateTime = doc['dateTime'];
                              final DateTime? dateTime =
                                  rawDateTime is Timestamp
                                      ? rawDateTime.toDate()
                                      : null;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: primary.withOpacity(0.1),
                                        width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        spreadRadius: 0,
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        // Notification icon with gradient
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.2),
                                                secondary.withOpacity(0.2),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.stars_rounded,
                                            color: primary,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 18),

                                        // Notification content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: 'Points Earned! 🎉',
                                                fontSize: 17,
                                                fontFamily: 'Bold',
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  TextWidget(
                                                    text: 'You earned ',
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          primary
                                                              .withOpacity(0.1),
                                                          secondary
                                                              .withOpacity(0.1),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: TextWidget(
                                                      text:
                                                          '${points.round().toStringAsFixed(0)} pts',
                                                      fontSize: 13,
                                                      fontFamily: 'Bold',
                                                      color: primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_rounded,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  TextWidget(
                                                    text: DateFormat.yMMMd()
                                                        .add_jm()
                                                        .format(dateTime ??
                                                            DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    0)),
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    bool isSelected = _filterType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected ? LinearGradient(colors: [primary, secondary]) : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : primary,
            ),
            const SizedBox(width: 8),
            TextWidget(
              text: label,
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontFamily: isSelected ? 'Bold' : 'Medium',
            ),
          ],
        ),
      ),
    );
  }
}
