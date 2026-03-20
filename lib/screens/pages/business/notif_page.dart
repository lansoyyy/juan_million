import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class BusinessNotifPage extends StatefulWidget {
  const BusinessNotifPage({super.key});

  @override
  State<BusinessNotifPage> createState() => _BusinessNotifPageState();
}

class _BusinessNotifPageState extends State<BusinessNotifPage> {
  String _filter = 'all';

  bool _passesFilter(DateTime time) {
    final now = DateTime.now();
    if (_filter == 'today') {
      return time.year == now.year &&
          time.month == now.month &&
          time.day == now.day;
    }
    if (_filter == 'week') {
      return now.difference(time).inDays <= 7;
    }
    if (_filter == 'month') {
      return time.year == now.year && time.month == now.month;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Notifications',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _chip('all', 'All'),
              _chip('today', 'Today'),
              _chip('week', 'This Week'),
              _chip('month', 'This Month'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Points').snapshots(),
              builder: (context, pointsSnapshot) {
                if (pointsSnapshot.hasError) {
                  return const Center(
                      child: Text('Error loading notifications'));
                }
                if (!pointsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Wallets')
                      .snapshots(),
                  builder: (context, walletsSnapshot) {
                    if (walletsSnapshot.hasError) {
                      return const Center(
                          child: Text('Error loading notifications'));
                    }
                    if (!walletsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final docs = <QueryDocumentSnapshot>[];
                    docs.addAll(pointsSnapshot.data!.docs
                        .where((doc) => doc['uid'] == uid));
                    docs.addAll(walletsSnapshot.data!.docs.where(
                      (doc) => doc['uid'] == uid || doc['from'] == uid,
                    ));

                    docs.sort((a, b) {
                      final dynamic aRaw = a['dateTime'];
                      final dynamic bRaw = b['dateTime'];
                      final DateTime aTime =
                          aRaw is Timestamp ? aRaw.toDate() : DateTime(2000);
                      final DateTime bTime =
                          bRaw is Timestamp ? bRaw.toDate() : DateTime(2000);
                      return bTime.compareTo(aTime);
                    });

                    final filtered = docs
                        .where((doc) {
                          final dynamic rawTime = doc['dateTime'];
                          final DateTime time = rawTime is Timestamp
                              ? rawTime.toDate()
                              : DateTime(2000);
                          return _passesFilter(time);
                        })
                        .take(40)
                        .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: TextWidget(
                          text: 'No notifications found',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final map =
                            filtered[index].data() as Map<String, dynamic>;
                        final dynamic rawPts = map['pts'];
                        final int pts = rawPts is num ? rawPts.toInt() : 0;
                        final String type =
                            map['type']?.toString() ?? 'Transaction';
                        final dynamic rawTime = map['dateTime'];
                        final DateTime time = rawTime is Timestamp
                            ? rawTime.toDate()
                            : DateTime(2000);

                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: blue.withOpacity(0.15),
                              child: Icon(Icons.notifications, color: blue),
                            ),
                            title: TextWidget(
                              text: type,
                              fontSize: 14,
                              fontFamily: 'Bold',
                              color: Colors.black87,
                            ),
                            subtitle: TextWidget(
                              text:
                                  '${DateFormat.yMMMd().add_jm().format(time)}\n$pts pts',
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              maxLines: 2,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: blue,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }
}
