import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rapport_page.dart'; // Assure-toi que le fichier existe

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  void _addEntry() {
    final TextEditingController lieuController = TextEditingController();
    final TextEditingController activitesController = TextEditingController();
    final TextEditingController competencesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter une journée'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: lieuController,
                    decoration: const InputDecoration(labelText: 'Lieu'),
                  ),
                  TextField(
                    controller: activitesController,
                    decoration: const InputDecoration(
                      labelText: 'Activités réalisées',
                    ),
                  ),
                  TextField(
                    controller: competencesController,
                    decoration: const InputDecoration(
                      labelText: 'Compétences acquises',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Changer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (lieuController.text.isNotEmpty &&
                      activitesController.text.isNotEmpty &&
                      competencesController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('journal')
                        .add({
                          'date': selectedDate,
                          'lieu': lieuController.text,
                          'activites': activitesController.text,
                          'competences': competencesController.text,
                        });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Suivi de stage - ${user!.displayName ?? user!.email ?? 'Utilisateur'}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: "Rédiger le rapport",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RapportPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection('journal')
                .orderBy('date')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Aucune journée ajoutée."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['lieu']),
                  subtitle: Text(
                    "${date.day}/${date.month}/${date.year}\n"
                    "Activités : ${data['activites']}\n"
                    "Compétences : ${data['competences']}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('journal')
                          .doc(docs[index].id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
