import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class TransactionReceiptDialog {
  static void showWalletReceipt(
    BuildContext context,
    dynamic doc, {
    String amountLabel = 'PHP',
  }) {
    if (doc == null) return;
    final Map<String, dynamic> data = doc is QueryDocumentSnapshot
        ? (doc.data() as Map<String, dynamic>)
        : (doc as Map<String, dynamic>);
    final String id =
        doc is QueryDocumentSnapshot ? doc.id : (data['id']?.toString() ?? '');

    final dynamic rawDate = data['dateTime'];
    DateTime? createdAt;
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is DateTime) {
      createdAt = rawDate;
    }

    final String createdStr =
        createdAt != null ? DateFormat.yMMMd().add_jm().format(createdAt) : '';

    final num amount = (data['pts'] ?? 0) is num ? data['pts'] as num : 0;
    final String type = data['type']?.toString() ?? 'Wallet Transaction';
    final String from = data['from']?.toString() ?? '';
    final String to = data['uid']?.toString() ?? '';
    final String cashier = data['cashier']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Transaction Receipt',
                      fontSize: 18,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: type,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      TextWidget(
                        text: amountLabel == 'PHP'
                            ? '₱ ${amount.toStringAsFixed(2)}'
                            : '$amount ${amountLabel.toUpperCase()}',
                        fontSize: 28,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      const SizedBox(height: 4),
                      if (createdStr.isNotEmpty)
                        TextWidget(
                          text: createdStr,
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Regular',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Reference ID',
                    id.isNotEmpty ? id : (data['id']?.toString() ?? 'N/A')),
                const SizedBox(height: 8),
                _buildInfoRow('From', from.isNotEmpty ? from : 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('To', to.isNotEmpty ? to : 'N/A'),
                if (cashier.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Processed By', cashier),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: TextWidget(
                      text: 'Done',
                      fontSize: 14,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showPointsReceipt(BuildContext context, dynamic doc) {
    if (doc == null) return;
    final Map<String, dynamic> data = doc is QueryDocumentSnapshot
        ? (doc.data() as Map<String, dynamic>)
        : (doc as Map<String, dynamic>);
    final String id =
        doc is QueryDocumentSnapshot ? doc.id : (data['id']?.toString() ?? '');

    final dynamic rawDate = data['dateTime'];
    DateTime? createdAt;
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is DateTime) {
      createdAt = rawDate;
    }

    final String createdStr =
        createdAt != null ? DateFormat.yMMMd().add_jm().format(createdAt) : '';

    final num pts = (data['pts'] ?? 0) is num ? data['pts'] as num : 0;
    final int qty =
        (data['qty'] ?? 0) is num ? (data['qty'] as num).toInt() : 0;
    final String type = data['type']?.toString() ?? 'Points Transaction';
    final String cashier = data['cashier']?.toString() ?? '';
    final String uid = data['uid']?.toString() ?? '';
    final String scannedId = data['scannedId']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Points Receipt',
                      fontSize: 18,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: type,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      TextWidget(
                        text: '${pts.toStringAsFixed(0)} pts',
                        fontSize: 28,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      const SizedBox(height: 4),
                      if (createdStr.isNotEmpty)
                        TextWidget(
                          text: createdStr,
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Regular',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Reference ID',
                    id.isNotEmpty ? id : (data['id']?.toString() ?? 'N/A')),
                const SizedBox(height: 8),
                _buildInfoRow('Quantity', qty > 0 ? qty.toString() : 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('Owner UID', uid.isNotEmpty ? uid : 'N/A'),
                if (scannedId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Scanned By', scannedId),
                ],
                if (cashier.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Processed By', cashier),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: TextWidget(
                      text: 'Done',
                      fontSize: 14,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showPaymentReceipt(BuildContext context, dynamic doc) {
    if (doc == null) return;
    final Map<String, dynamic> data = doc is QueryDocumentSnapshot
        ? (doc.data() as Map<String, dynamic>)
        : (doc as Map<String, dynamic>);
    final String id = doc is QueryDocumentSnapshot
        ? doc.id
        : (data['txnId']?.toString() ?? '');

    final dynamic rawDate = data['createdAt'];
    DateTime? createdAt;
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is DateTime) {
      createdAt = rawDate;
    }

    final String createdStr =
        createdAt != null ? DateFormat.yMMMd().add_jm().format(createdAt) : '';

    final String currency = data['currency']?.toString() ?? 'PHP';
    final String amount = data['amount']?.toString() ?? '0.00';
    final String description =
        data['description']?.toString() ?? 'Payment Transaction';
    final String status = data['status']?.toString() ?? 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Payment Receipt',
                      fontSize: 18,
                      fontFamily: 'Bold',
                      color: Colors.black87,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: description,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      TextWidget(
                        text: '$currency $amount',
                        fontSize: 28,
                        fontFamily: 'Bold',
                        color: primary,
                      ),
                      const SizedBox(height: 4),
                      if (createdStr.isNotEmpty)
                        TextWidget(
                          text: createdStr,
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Regular',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Transaction ID', id.isNotEmpty ? id : 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('Status', status),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: TextWidget(
                      text: 'Done',
                      fontSize: 14,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: TextWidget(
            text: label,
            fontSize: 12,
            color: Colors.grey.shade700,
            fontFamily: 'Medium',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 13,
            color: Colors.black87,
            fontFamily: 'Regular',
          ),
        ),
      ],
    );
  }
}
