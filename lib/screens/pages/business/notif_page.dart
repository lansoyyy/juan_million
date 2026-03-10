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

  Stream<List<QueryDocumentSnapshot>> _getNotifications() async* {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final pointsQuery = FirebaseFirestore.instance
        .collection('Points')
        .where('uid', isEqualTo: uid)
        .orderBy('dateTime', descending: true)
        .limit(30);

    await for (final pointsSnap in pointsQuery.snapshots()) {
      final sentWalletsSnap = await FirebaseFirestore.instance
          .collection('Wallets')
          .where('from', isEqualTo: uid)
          .orderBy('dateTime', descending: true)
          .limit(30)
          .get();

      final receivedWalletsSnap = await FirebaseFirestore.instance
          .collection('Wallets')
          .where('uid', isEqualTo: uid)
          .orderBy('dateTime', descending: true)
          .limit(30)
          .get();

      final combined = <QueryDocumentSnapshot>[];
      combined.addAll(pointsSnap.docs);
      combined.addAll(sentWalletsSnap.docs);
      combined.addAll(receivedWalletsSnap.docs);

      combined.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final DateTime aTime = aData['dateTime'] is Timestamp
            ? (aData['dateTime'] as Timestamp).toDate()
            : DateTime(2000);
        final DateTime bTime = bData['dateTime'] is Timestamp
            ? (bData['dateTime'] as Timestamp).toDate()
            : DateTime(2000);
        return bTime.compareTo(aTime);
      });

      yield combined.take(40).toList();
    }
  }

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
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading notifications'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!;
                final filtered = docs.where((doc) {
                  final map = doc.data() as Map<String, dynamic>;
                  final dynamic rawTime = map['dateTime'];
                  final DateTime time = rawTime is Timestamp
                      ? rawTime.toDate()
                      : DateTime(2000);
                  return _passesFilter(time);
                }).toList();

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
                    final map = filtered[index].data() as Map<String, dynamic>;
                    final dynamic rawPts = map['pts'];
                    final int pts = rawPts is num ? rawPts.toInt() : 0;
                    final String type = map['type']?.toString() ?? 'Transaction';
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
                          text: '${DateFormat.yMMMd().add_jm().format(time)}\n$pts pts',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          maxLines: 2,
                        ),
                      ),
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
