import 'package:flutter/material.dart';
import 'account_page.dart'; // Importer la page de compte

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Liste des pages correspondant aux onglets
  final List<Widget> _pages = [
    HomeScreen(),               // Page d'accueil
    Center(child: Text('Parcourir')), // Onglet "Parcourir"
    Center(child: Text('Commandes')), // Onglet "Commandes"
    AccountPage(),              // Onglet "Compte"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Page active
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: 'Parcourir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 30),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 30),
            label: 'Compte',  // L'onglet "Compte"
          ),
        ],
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}

// Exemple de page d'accueil modernisée
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header blanc uni
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche modernisée
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un restaurant ou un produit',
                      prefixIcon: Icon(Icons.search, color: Colors.orange),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Catégories
                Text(
                  'Catégories populaires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Pizza'),
                      _buildCategoryChip('Burgers'),
                      _buildCategoryChip('Sushi'),
                      _buildCategoryChip('Salades'),
                      _buildCategoryChip('Desserts'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Liste des restaurants avec cartes
                Text(
                  'Restaurants populaires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5, // Remplacez par le nombre réel de restaurants
                  itemBuilder: (context, index) {
                    return _buildRestaurantCard(
                      name: 'Restaurant $index',
                      isOpen: index % 2 == 0, // Alternance entre ouvert et fermé
                      nextOpening: '10:00', // Heure d'ouverture (exemple)
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour une puce de catégorie
  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.orange.withOpacity(0.2),
      ),
    );
  }

  // Widget pour une carte de restaurant avec le nom et statut
  Widget _buildRestaurantCard({
    required String name,
    required bool isOpen,
    required String nextOpening,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de fond (ou une couleur temporaire)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blueGrey, // Remplacer par une vraie image plus tard
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Informations sous la carte
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Affichage du statut
                Text(
                  isOpen ? 'Ouvert' : 'Fermé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                // Prochaine heure d'ouverture
                if (!isOpen)
                  Text(
                    'Prochaine ouverture: $nextOpening',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
