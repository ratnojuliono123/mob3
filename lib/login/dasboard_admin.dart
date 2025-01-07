import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mob3_ubg_kelompok12/home_Page/homepage.dart';
import 'package:mob3_ubg_kelompok12/input_data/anggota_page.dart';
import 'package:mob3_ubg_kelompok12/input_data/data_angsuran.dart';
import 'package:mob3_ubg_kelompok12/input_data/data_pinjaman.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  _DashboardAdminPageState createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _selectedIndex = 0;

  // Initialize a PageController to handle page navigation
  final PageController _pageController = PageController();

  // Fetch counts from Firestore
  int anggotaCount = 0;
  int pinjamanCount = 0;
  int angsuranCount = 0;

  void getCounts() async {
    var anggotaSnapshot =
        await FirebaseFirestore.instance.collection('anggota').get();
    var pinjamanSnapshot =
        await FirebaseFirestore.instance.collection('pinjaman').get();
    var angsuranSnapshot =
        await FirebaseFirestore.instance.collection('angsuran').get();

    setState(() {
      anggotaCount = anggotaSnapshot.docs.length;
      pinjamanCount = pinjamanSnapshot.docs.length;
      angsuranCount = angsuranSnapshot.docs.length;
    });
  }

  // Function to handle bottom navigation changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Navigate to the selected page
  }

  @override
  void initState() {
    super.initState();
    getCounts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 // Show the AppBar only for Dashboard
          ? AppBar(
              title: const Text(
                'Dashboard',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.deepPurpleAccent,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
              ],
            )
          : null, // Hide the AppBar for other pages
      body: PageView(
        controller: _pageController, // Set the controller for the PageView
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change page
        children: [
          _buildDashboardPage(),
          AnggotaPage(),
          DataPinjamanPage(),
          DataAngsuranScreen(),
        ],
      ),
      // Bottom navigation bar with custom colors
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Data Anggota',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Data Pinjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Data Angsuran',
          ),
        ],
      ),
    );
  }

  // Dashboard page widget
  Widget _buildDashboardPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Anggota', anggotaCount, Icons.group, 
                   Colors.teal.shade400),
                _buildStatCard('Pinjaman', pinjamanCount, Icons.attach_money,
                    Colors.green.shade400),
                _buildStatCard('Angsuran', angsuranCount, Icons.payment,
                    Colors.blue.shade400),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,  
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.group,
                  title: 'Data Anggota',
                  color: Colors.teal.shade300,
                  onTap: () {
                    _onItemTapped(1); // Navigate to 'Data Anggota'
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.attach_money,
                  title: 'Data Pinjaman',
                  color: Colors.green.shade300,
                  onTap: () {
                    _onItemTapped(2); // Navigate to 'Data Pinjaman'
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.payment,
                  title: 'Data Angsuran',
                  color: Colors.blue.shade300,
                  onTap: () {
                    _onItemTapped(3); // Navigate to 'Data Angsuran'
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom stat card with count and icon
  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: color,
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          '$title',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Menu card
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: color,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}