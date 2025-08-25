import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/admin/report/report_card.dart';
import 'package:l_f/Frontend/Home/admin/report/reported_post_dialog.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Post Reports"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No reports found. All clear! 👍",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final reportData = report.data() as Map<String, dynamic>;
              return ReportCard(
                report: report,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => ReportedPostDialog(
                      reportId: report.id,
                      postId: reportData['postId'],
                      postOwnerId: reportData['postOwnerId'],
                      // --- CHANGE IS HERE: Pass the reporter's ID ---
                      reporterId: reportData['reporterId'],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
