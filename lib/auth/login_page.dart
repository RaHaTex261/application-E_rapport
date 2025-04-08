import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Erreur inconnue';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 10),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: login, child: const Text('Se connecter')),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
              child: const Text("Pas de compte ? S'inscrire"),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Réinitialiser le mot de passe"),
                      content: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Entrez votre email',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                    email: emailController.text.trim(),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email de réinitialisation envoyé !',
                                  ),
                                ),
                              );
                              Navigator.pop(
                                context,
                              ); // Ferme la fenêtre de dialogue
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message ?? 'Erreur inconnue'),
                                ),
                              );
                            }
                          },
                          child: const Text('Envoyer'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pop(
                                context,
                              ), // Ferme la fenêtre de dialogue
                          child: const Text('Annuler'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Mot de passe oublié ?"),
            ),
          ],
        ),
      ),
    );
  }
}
