import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'afficher_rapport_page.dart';

class RapportPage extends StatefulWidget {
  const RapportPage({super.key});

  @override
  State<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage> {
  final TextEditingController presentationController = TextEditingController();
  final TextEditingController objectifsController = TextEditingController();
  final TextEditingController missionsController = TextEditingController();
  final TextEditingController difficultesController = TextEditingController();
  final TextEditingController conclusionController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadRapport();
  }

  Future<void> _loadRapport() async {
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('rapport')
            .doc('contenu')
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      presentationController.text = data['presentation'] ?? '';
      objectifsController.text = data['objectifs'] ?? '';
      missionsController.text = data['missions'] ?? '';
      difficultesController.text = data['difficultes'] ?? '';
      conclusionController.text = data['conclusion'] ?? '';
    }
  }

  Future<void> _saveRapport() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('rapport')
        .doc('contenu')
        .set({
          'presentation': presentationController.text,
          'objectifs': objectifsController.text,
          'missions': missionsController.text,
          'difficultes': difficultesController.text,
          'conclusion': conclusionController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rapport enregistré avec succès 📝")),
    );
  }

  void _exportToPDF() async {
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
                presentationController.text,
              ),
              _buildPDFSection("Objectifs du stage", objectifsController.text),
              _buildPDFSection("Missions réalisées", missionsController.text),
              _buildPDFSection(
                "Difficultés rencontrées",
                difficultesController.text,
              ),
              _buildPDFSection("Conclusion", conclusionController.text),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(content, style: const pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rédiger le rapport")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSection(
              "Présentation de l’entreprise",
              presentationController,
            ),
            _buildSection("Objectifs du stage", objectifsController),
            _buildSection("Missions réalisées", missionsController),
            _buildSection("Difficultés rencontrées", difficultesController),
            _buildSection("Conclusion", conclusionController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRapport,
              child: const Text("Enregistrer dans Firestore"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AfficherRapportPage(),
                  ),
                );
              },
              child: const Text("Voir mon rapport"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _exportToPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Exporter en PDF"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
