import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AfficherRapportPage extends StatelessWidget {
  const AfficherRapportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté.")),
      );
    }

    final rapportRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('rapport')
        .doc('contenu');

    return Scaffold(
      appBar: AppBar(title: const Text("Mon rapport de stage")),
      body: FutureBuilder<DocumentSnapshot>(
        future: rapportRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Aucun rapport trouvé."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _buildSection(
                  "Présentation de l’entreprise",
                  data['presentation'],
                ),
                _buildSection("Objectifs du stage", data['objectifs']),
                _buildSection("Missions réalisées", data['missions']),
                _buildSection("Difficultés rencontrées", data['difficultes']),
                _buildSection("Conclusion", data['conclusion']),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _exportToPDF(data),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Exporter en PDF"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _exportToPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Text(
                "Mon Rapport de Stage",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPDFSection(
                "Présentation de l’entreprise",
                data['presentation'],
              ),
              _buildPDFSection("Objectifs du stage", data['objectifs']),
              _buildPDFSection("Missions réalisées", data['missions']),
              _buildPDFSection("Difficultés rencontrées", data['difficultes']),
              _buildPDFSection("Conclusion", data['conclusion']),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSection(String title, String? content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(content ?? "-", style: const pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSection(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(content ?? "-", style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
