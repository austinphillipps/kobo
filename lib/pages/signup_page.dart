import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serialNumberController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  String _calculatePasswordStrength(String password) {
    if (password.isEmpty) return '';

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;
    if (password.length >= 8) strength++;

    setState(() {
      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Très faible';
          _passwordStrengthColor = Colors.red;
          break;
        case 2:
          _passwordStrength = 'Faible';
          _passwordStrengthColor = Colors.orange;
          break;
        case 3:
          _passwordStrength = 'Moyen';
          _passwordStrengthColor = Colors.yellow;
          break;
        case 4:
          _passwordStrength = 'Fort';
          _passwordStrengthColor = Colors.lightGreen;
          break;
        case 5:
          _passwordStrength = 'Très fort';
          _passwordStrengthColor = Colors.green;
          break;
      }
    });

    return _passwordStrength;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérification du numéro de série
      final serialSnapshot = await FirebaseFirestore.instance
          .collection('serialNumbers')
          .where('code', isEqualTo: _serialNumberController.text.trim())
          .where('used', isEqualTo: false)
          .get();

      if (serialSnapshot.docs.isEmpty) {
        throw 'Numéro de série invalide ou déjà utilisé';
      }

      final serialDoc = serialSnapshot.docs.first;
      final serialData = serialDoc.data();
      final String role = serialData['role'] ?? 'client';

      // Créer l'utilisateur dans Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Créer le document utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
      });

      // Marquer le numéro de série comme utilisé
      await FirebaseFirestore.instance
          .collection('serialNumbers')
          .doc(serialDoc.id)
          .update({
        'used': true,
        'usedBy': userCredential.user!.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie !')),
      );

      // Redirection selon le rôle
      String route;
      switch (role) {
        case 'admin':
          route = '/admin-dashboard';
          break;
        case 'restaurant':
          route = '/restaurant-dashboard';
          break;
        case 'driver':
          route = '/driver-dashboard';
          break;
        default:
          route = '/home';
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'Cette adresse email est déjà utilisée.';
            break;
          case 'invalid-email':
            _errorMessage = 'L\'adresse email n\'est pas valide.';
            break;
          case 'operation-not-allowed':
            _errorMessage = 'L\'inscription par email/mot de passe n\'est pas activée.';
            break;
          case 'weak-password':
            _errorMessage = 'Le mot de passe est trop faible.';
            break;
          default:
            _errorMessage = 'Une erreur est survenue : ${e.message}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un email';
                        }
                        if (!value.contains('@')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            _passwordStrength,
                            style: TextStyle(color: _passwordStrengthColor),
                          ),
                        ),
                      ),
                      obscureText: true,
                      onChanged: _calculatePasswordStrength,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 8) {
                          return 'Le mot de passe doit contenir au moins 8 caractères';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Le mot de passe doit contenir au moins une majuscule';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Le mot de passe doit contenir au moins une minuscule';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Le mot de passe doit contenir au moins un chiffre';
                        }
                        if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                          return 'Le mot de passe doit contenir au moins un caractère spécial';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _serialNumberController,
                      decoration: InputDecoration(
                        labelText: 'Numéro de série',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro de série';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text('S\'inscrire'),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              "Déjà un compte ? Connectez-vous",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
