import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAngsuranBottomSheet extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddAngsuranBottomSheet({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController jumlahController = TextEditingController();
    TextEditingController tanggalController = TextEditingController();
    String status = 'Belum Lunas';  // Status bawaan

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tambah Angsuran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          TextFormField(
            controller: tanggalController,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.date_range),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: jumlahController,
            decoration: InputDecoration(
              labelText: 'Jumlah',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Status: ', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: status,
                onChanged: (String? newValue) {
                  status = newValue!;
                },
                items: <String>['Belum Lunas', 'Lunas']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> newAngsuran = {
                'tanggal': tanggalController.text,
                'jumlah': int.tryParse(jumlahController.text) ?? 0,
                'status': status, // Status akan ditetapkan dari dropdown
              };
              onSubmit(newAngsuran);
              Navigator.pop(context); // Tutup lembar terbawah setelah penyerahan
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Tambah', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class EditAngsuranBottomSheet extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final Function(Map<String, dynamic>) onUpdate;

  const EditAngsuranBottomSheet({Key? key, required this.currentData, required this.onUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController jumlahController = TextEditingController(text: currentData['jumlah'].toString());
    TextEditingController tanggalController = TextEditingController(text: currentData['tanggal']);
    String status = currentData['status'];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit Angsuran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          TextFormField(
            controller: tanggalController,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.date_range),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: jumlahController,
            decoration: InputDecoration(
              labelText: 'Jumlah',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Status: ', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: status,
                onChanged: (String? newValue) {
                  status = newValue!;
                },
                items: <String>['Belum Lunas', 'Lunas']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> updatedAngsuran = {
                'tanggal': tanggalController.text,
                'jumlah': int.tryParse(jumlahController.text) ?? 0,
                'status': status,
              };
              onUpdate(updatedAngsuran);
              Navigator.pop(context); // Tutup lembar bawah setelah memperbarui
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Update', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class DataAngsuranScreen extends StatefulWidget {
  @override
  _DataAngsuranScreenState createState() => _DataAngsuranScreenState();
}

class _DataAngsuranScreenState extends State<DataAngsuranScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAngsuran(Map<String, dynamic> newAngsuran) async {
    await _firestore.collection('angsuran').add(newAngsuran);
  }

  Future<void> updateAngsuran(String docId, Map<String, dynamic> updatedAngsuran) async {
    await _firestore.collection('angsuran').doc(docId).update(updatedAngsuran);
  }

  Future<void> deleteAngsuran(String docId) async {
    await _firestore.collection('angsuran').doc(docId).delete();
  }

  int calculateTotalRemainingAmount(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs
        .where((doc) => doc['status'] == 'Belum Lunas')
        .fold<int>(0, (sum, item) => sum + (item['jumlah'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('angsuran').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Data Angsuran');
            }

            final remainingAngsuran = snapshot.data!.docs
                .where((doc) => doc['status'] == 'Belum Lunas')
                .length;

            final totalRemaining = calculateTotalRemainingAmount(snapshot);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Angsuran', style: TextStyle(fontSize: 16)),
                Text(
                  'Sisa Angsuran: $remainingAngsuran kali, Total Sisa: Rp$totalRemaining',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('angsuran').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final angsuranDocs = snapshot.data!.docs;

          return Column(
            children: [
              TableHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: angsuranDocs.length,
                  itemBuilder: (context, index) {
                    final doc = angsuranDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return TableRowWidget(
                      no: index + 1,
                      tanggal: data['tanggal'],
                      jumlah: data['jumlah'],
                      status: data['status'],
                      onDelete: () => deleteAngsuran(doc.id),
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => EditAngsuranBottomSheet(
                            currentData: data,
                            onUpdate: (updatedData) {
                              updateAngsuran(doc.id, updatedData);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => AddAngsuranBottomSheet(onSubmit: addAngsuran),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget TableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final int no;
  final String tanggal;
  final int jumlah;
  final String status;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TableRowWidget({
    Key? key,
    required this.no,
    required this.tanggal,
    required this.jumlah,
    required this.status,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text('$no. $tanggal - Rp$jumlah', style: TextStyle(fontSize: 16)),
        subtitle: Text(status, style: TextStyle(color: status == 'Belum Lunas' ? Colors.orange : Colors.green)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: Colors.blue)),
            IconButton(onPressed: onDelete, icon: Icon(Icons.delete, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
