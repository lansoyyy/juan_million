import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('Payments')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    Color _statusColor(String status) {
      switch (status) {
        case 'Successful':
          return Colors.green;
        case 'Failed':
          return Colors.red;
        default:
          return Colors.orange; // Pending or others
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading payments'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: TextWidget(
                text: 'No payments yet',
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Regular',
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final txnId = data['txnId'] ?? docs[index].id;
              final amount = data['amount'] ?? '0.00';
              final currency = data['currency'] ?? 'PHP';
              final description = data['description'] ?? '';
              final status = data['status'] ?? 'Pending';
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

              final createdStr = createdAt != null
                  ? DateFormat.yMMMd().add_jm().format(createdAt)
                  : '';
              final updatedStr = updatedAt != null
                  ? DateFormat.yMMMd().add_jm().format(updatedAt)
                  : '';

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        text: description.isNotEmpty
                            ? description
                            : 'Transaction $txnId',
                        fontSize: 14,
                        fontFamily: 'Bold',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusColor(status)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Txn ID: $txnId'),
                      const SizedBox(height: 2),
                      Text('Amount: $currency $amount'),
                      if (createdStr.isNotEmpty) Text('Created: $createdStr'),
                      if (updatedStr.isNotEmpty) Text('Updated: $updatedStr'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
