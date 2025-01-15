// lib/pages/admin/serial_numbers_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SerialNumbersPage extends StatefulWidget {
  @override
  _SerialNumbersPageState createState() => _SerialNumbersPageState();
}

class _SerialNumbersPageState extends State<SerialNumbersPage> {
  String _selectedRole = 'restaurant';
  bool _isGenerating = false;

  Future<void> _generateSerialNumber() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final serialNumber = Uuid().v4().substring(0, 8).toUpperCase();

      await FirebaseFirestore.instance.collection('serialNumbers').add({
        'number': serialNumber,
        'role': _selectedRole,
        'isUsed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numéro de série généré : $serialNumber')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération : $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des numéros de série'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'restaurant',
                        child: Text('Restaurant'),
                      ),
                      DropdownMenuItem(
                        value: 'driver',
                        child: Text('Livreur'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrateur'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateSerialNumber,
                  child: _isGenerating
                      ? CircularProgressIndicator()
                      : Text('Générer'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('serialNumbers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final serialNumbers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: serialNumbers.length,
                  itemBuilder: (context, index) {
                    final serialData =
                    serialNumbers[index].data() as Map<String, dynamic>;
                    final isUsed = serialData['isUsed'] ?? false;
                    final usedBy = serialData['usedBy'];
                    final role = serialData['role'];
                    final number = serialData['number'];

                    return ListTile(
                      title: Text(number),
                      subtitle: Text('Rôle: $role'),
                      trailing: Icon(
                        isUsed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isUsed ? Colors.green : Colors.grey,
                      ),
                      onTap: () async {
                        if (isUsed && usedBy != null) {
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(usedBy)
                              .get();
                          if (userDoc.exists) {
                            final userData = userDoc.data()!;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Détails'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${userData['email']}'),
                                    Text('Rôle: ${userData['role']}'),
                                    Text('Date: ${(userData['createdAt'] as Timestamp).toDate()}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Fermer'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
