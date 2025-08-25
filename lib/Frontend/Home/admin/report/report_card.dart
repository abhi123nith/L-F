import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final QueryDocumentSnapshot report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final data = report.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';
    final reason = data['reason'] ?? 'No reason provided';
    final details = data['details'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: status == 'approved'
              ? Colors.green
              : status == 'dismissed'
                  ? Colors.grey
                  : Colors.orange,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: status == 'approved'
                        ? Colors.green
                        : status == 'dismissed'
                            ? Colors.grey
                            : Colors.orange,
                  ),
                ],
              ),
              if (details.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Details: "$details"',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                  ),
                ),
              const Divider(height: 20),
              Text(
                'Post ID: ${report['postId']}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'Reported on: ${_formatTimestamp(data['timestamp'] as Timestamp?)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
