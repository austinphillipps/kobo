import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Variables pour stocker les adresses
  String? displayName = "Prénom Nom";
  String? homeAddress = "Non renseignée";
  String? workAddress = "Non renseignée";
  String? otherAddress = "Non renseignée";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            displayName = "${userData['surname'] ?? 'Prénom'} ${userData['name'] ?? 'Nom'}";
            homeAddress = userData['address'] ?? "Non renseignée";
          });
        }
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur : $e");
    }
  }

  // Méthode pour afficher le popup de modification
  void _showAddressDialog({
    required String title,
    required String currentAddress,
    required Function(String) onSave,
  }) {
    TextEditingController controller = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nouvelle adresse',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compte'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil utilisateur
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.account_circle, size: 60),
                  ),
                  SizedBox(height: 10),
                  Text(
                    displayName ?? "Prénom Nom",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Titre "Lieux enregistrés"
            Container(
              width: double.infinity,
              color: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                'Lieux enregistrés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Lieux enregistrés avec champs modifiables
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildLocationItem(
                    icon: Icons.home,
                    label: 'Domicile',
                    address: homeAddress,
                    onEdit: () {
                      _showAddressDialog(
                        title: 'Domicile',
                        currentAddress: homeAddress ?? '',
                        onSave: (newAddress) async {
                          setState(() {
                            homeAddress = newAddress;
                          });
                          if (user != null) {
                            await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                              'address': newAddress,
                            });
                          }
                        },
                      );
                    },
                  ),
                  _buildLocationItem(
                    icon: Icons.business,
                    label: 'Bureau',
                    address: workAddress,
                    onEdit: () {
                      _showAddressDialog(
                        title: 'Bureau',
                        currentAddress: workAddress ?? '',
                        onSave: (newAddress) {
                          setState(() {
                            workAddress = newAddress;
                          });
                        },
                      );
                    },
                  ),
                  _buildLocationItem(
                    icon: Icons.location_on,
                    label: 'Autre lieu',
                    address: otherAddress,
                    onEdit: () {
                      _showAddressDialog(
                        title: 'Autre lieu',
                        currentAddress: otherAddress ?? '',
                        onSave: (newAddress) {
                          setState(() {
                            otherAddress = newAddress;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Bouton de déconnexion
            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour chaque lieu enregistré
  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required String? address,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black), // Icône noire
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  address ?? 'Non renseignée',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.orange),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
