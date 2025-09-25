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
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: 'Notifications',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('All Notifications'),
                ),
                const PopupMenuItem<String>(
                  value: 'today',
                  child: Text('Today'),
                ),
                const PopupMenuItem<String>(
                  value: 'week',
                  child: Text('This Week'),
                ),
                const PopupMenuItem<String>(
                  value: 'month',
                  child: Text('This Month'),
                ),
              ];
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Points')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print('error');
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            }

            final data = snapshot.requireData;

            // Filter notifications based on selected filter
            List<QueryDocumentSnapshot> filteredDocs = [];
            DateTime now = DateTime.now();

            if (_filterType == 'all') {
              filteredDocs = data.docs.toList();
            } else if (_filterType == 'today') {
              filteredDocs = data.docs.where((doc) {
                DateTime docDate = (doc['dateTime'] as Timestamp).toDate();
                return docDate.day == now.day &&
                    docDate.month == now.month &&
                    docDate.year == now.year;
              }).toList();
            } else if (_filterType == 'week') {
              filteredDocs = data.docs.where((doc) {
                DateTime docDate = (doc['dateTime'] as Timestamp).toDate();
                return now.difference(docDate).inDays <= 7;
              }).toList();
            } else if (_filterType == 'month') {
              filteredDocs = data.docs.where((doc) {
                DateTime docDate = (doc['dateTime'] as Timestamp).toDate();
                return docDate.month == now.month && docDate.year == now.year;
              }).toList();
            }

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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 10),
                        _buildFilterChip('Today', 'today'),
                        const SizedBox(width: 10),
                        _buildFilterChip('This Week', 'week'),
                        const SizedBox(width: 10),
                        _buildFilterChip('This Month', 'month'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notifications list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        double points = filteredDocs[index]['pts'].toDouble();
                        DateTime dateTime =
                            (filteredDocs[index]['dateTime'] as Timestamp)
                                .toDate();

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Container(
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
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  // Notification icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // Notification content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Points Earned',
                                          fontSize: 16,
                                          fontFamily: 'Bold',
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(height: 5),
                                        TextWidget(
                                          text:
                                              'You earned ${points.round().toStringAsFixed(0)} points',
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        const SizedBox(height: 5),
                                        TextWidget(
                                          text: DateFormat.yMMMd()
                                              .add_jm()
                                              .format(dateTime),
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Notification status
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 16,
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
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextWidget(
          text: label,
          fontSize: 14,
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontFamily: isSelected ? 'Medium' : 'Regular',
        ),
      ),
    );
  }
}
