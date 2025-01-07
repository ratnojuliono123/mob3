import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pinjaman {
  String id;
  String nama;
  String alamat;
  String noHp;
  String email;
  double jumlah;
  DateTime tanggal;

  Pinjaman({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.email,
    required this.jumlah,
    required this.tanggal,
  });
}

class DataPinjamanPage extends StatefulWidget {
  @override
  _DataPinjamanPageState createState() => _DataPinjamanPageState();
}

class _DataPinjamanPageState extends State<DataPinjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _jumlahController = TextEditingController();

  void _addPinjaman() async {
    if (_formKey.currentState!.validate()) {
      final pinjaman = Pinjaman(
        id: DateTime.now().toString(),
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: _noHpController.text,
        email: _emailController.text,
        jumlah: double.parse(_jumlahController.text),
        tanggal: DateTime.now(),
      );

      try {
        // Simpan data ke Firestore
        await FirebaseFirestore.instance.collection('pinjaman').add({
          'nama': pinjaman.nama,
          'alamat': pinjaman.alamat,
          'noHp': pinjaman.noHp,
          'email': pinjaman.email,
          'jumlah': pinjaman.jumlah,
          'tanggal': pinjaman.tanggal.toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil ditambahkan')),
        );

        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah data: $error')),
        );
      }
    }
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _noHpController.clear();
    _emailController.clear();
    _jumlahController.clear();
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: isNumeric
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label harus diisi';
        }
        if (isEmail && !value.contains('@')) {
          return 'Masukkan email yang valid';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Pinjaman',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.lightBlue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk input data
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pinjaman',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(_namaController, 'Nama'),
                  SizedBox(height: 10),
                  _buildTextField(_alamatController, 'Alamat'),
                  SizedBox(height: 10),
                  _buildTextField(_noHpController, 'No. HP'),
                  SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', isEmail: true),
                  SizedBox(height: 10),
                  _buildTextField(_jumlahController, 'Jumlah Pinjaman',
                      isNumeric: true),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addPinjaman,
                    child: Text(
                      'Tambah',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // List data pinjaman dari Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pinjaman')
                    .orderBy('tanggal', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada data pinjaman',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final data = documents[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            data['nama'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Alamat: ${data['alamat']}\n'
                            'No. HP: ${data['noHp']}\n'
                            'Email: ${data['email']}\n'
                            'Jumlah: Rp${data['jumlah']}\n'
                            'Tanggal: ${data['tanggal'].split('T')[0]}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
