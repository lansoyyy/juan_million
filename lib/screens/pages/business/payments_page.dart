import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('Payments')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    // Check if desktop
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: blue,
              foregroundColor: Colors.white,
              title: TextWidget(
                text: 'Payments',
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Medium',
              ),
              centerTitle: true,
            ),
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSidebar(context),
                Expanded(
                  child: _buildContent(context, stream),
                ),
              ],
            )
          : _buildContent(context, stream),
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
                    icon: Icons.payment_rounded,
                    label: 'Payments',
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

  Widget _buildContent(BuildContext context, Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment_outlined,
                      color: blue,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextWidget(
                    text: 'No Payments Yet',
                    fontSize: 18,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text: 'Your payment history will appear here',
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final txnId = data['txnId'] ?? docs[index].id;
              final amount = data['amount'] ?? '0.00';
              final currency = data['currency'] ?? 'PHP';
              final description = data['description'] ?? '';
              final status = data['status'] ?? 'Pending';
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

              final createdStr = createdAt != null
                  ? DateFormat.yMMMd().add_jm().format(createdAt)
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextWidget(
                                text: description.isNotEmpty
                                    ? description
                                    : 'Transaction',
                                fontSize: 16,
                                fontFamily: 'Bold',
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextWidget(
                                text: status,
                                fontSize: 12,
                                color: _statusColor(status),
                                fontFamily: 'Bold',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'Amount',
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Regular',
                                  ),
                                  const SizedBox(height: 4),
                                  TextWidget(
                                    text: '$currency $amount',
                                    fontSize: 18,
                                    color: blue,
                                    fontFamily: 'Bold',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.tag, color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextWidget(
                                text: 'ID: $txnId',
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'Regular',
                              ),
                            ),
                          ],
                        ),
                        if (createdStr.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Colors.grey, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextWidget(
                                  text: createdStr,
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: 'Regular',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
