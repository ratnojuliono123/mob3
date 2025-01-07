import 'package:flutter/material.dart';
import 'package:mob3_ubg_kelompok12/authentication/authentication.dart';

import 'package:mob3_ubg_kelompok12/login/dasboard_admin.dart';
import 'package:mob3_ubg_kelompok12/login/form_login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 6, 223),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.account_circle,
                        size: 50, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email Pengguna', // Gantilah ini dengan email pengguna yang sedang login
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardAdminPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app), // Ikon untuk log out
              title: const Text('Log Out'),
              onTap: () {
                Authentication().logOut(); // Fungsi logOut untuk keluar
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                           LoginPage()), // Setelah logout, arahkan ke LoginScreen
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DashboardAdminPage()),
            );
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 45, 6, 2236)),
          child: const Text('Pergi ke Dashboard'),
        ),
      ),
    );
  }
}