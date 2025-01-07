import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnggotaPage extends StatefulWidget {
  @override
  _AnggotaPageState createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final CollectionReference anggotaCollection =
      FirebaseFirestore.instance.collection('anggota');

  // Fungsi Tambah Anggota Baru
  void _tambahAnggota() {
    _showAnggotaSheet(
      title: "Tambah Anggota Baru",
      onSubmit: (nama, alamat, biodata) async {
        await anggotaCollection.add({
          "nama": nama.trim(),
          "alamat": alamat.trim(),
          "biodata": biodata.trim(),
        });
      },
    );
  }

  // Fungsi Edit Anggota
  void _editAnggota(String docId, Map<String, dynamic> anggota) {
    _showAnggotaSheet(
      title: "Edit Anggota",
      initialNama: anggota["nama"],
      initialAlamat: anggota["alamat"],
      initialBiodata: anggota["biodata"],
      onSubmit: (nama, alamat, biodata) async {
        await anggotaCollection.doc(docId).update({
          "nama": nama.trim(),
          "alamat": alamat.trim(),
          "biodata": biodata.trim(),
        });
      },
    );
  }

  // Fungsi Hapus Anggota
  void _hapusAnggota(String docId) async {
    await anggotaCollection.doc(docId).delete();
  }

  // Bottom Sheet Tambah/Edit Anggota
  void _showAnggotaSheet({
    required String title,
    String? initialNama,
    String? initialAlamat,
    String? initialBiodata,
    required Function(String nama, String alamat, String biodata) onSubmit,
  }) {
    final namaController = TextEditingController(text: initialNama);
    final alamatController = TextEditingController(text: initialAlamat);
    final biodataController = TextEditingController(text: initialBiodata);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: "Nama",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: "Alamat",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: biodataController,
                  decoration: InputDecoration(
                    labelText: "Biodata/Jabatan",
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (namaController.text.isNotEmpty &&
                            alamatController.text.isNotEmpty &&
                            biodataController.text.isNotEmpty) {
                          onSubmit(
                            namaController.text,
                            alamatController.text,
                            biodataController.text,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Semua kolom harus diisi!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text("Simpan"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Anggota"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: anggotaCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan"));
          }

          final anggotaDocs = snapshot.data?.docs ?? [];
          if (anggotaDocs.isEmpty) {
            return Center(child: Text("Belum ada data anggota"));
          }

          return ListView.builder(
            itemCount: anggotaDocs.length,
            itemBuilder: (context, index) {
              final doc = anggotaDocs[index];
              final anggota = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text(
                      anggota["nama"]![0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    anggota["nama"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${anggota["alamat"]} - ${anggota["biodata"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editAnggota(doc.id, anggota),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusAnggota(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahAnggota,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
