import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int anggotaCount = 0;
  int pinjamanCount = 0;
  int angsuranCount = 0;

  @override
  void initState() {
    super.initState();
    getCounts();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardCard(
              title: "Total Anggota",
              count: anggotaCount,
              color: Colors.blue,
              icon: Icons.group,
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: "Total Pinjaman",
              count: pinjamanCount,
              color: Colors.green,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: "Total Angsuran",
              count: angsuranCount,
              color: Colors.orange,
              icon: Icons.credit_card,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
