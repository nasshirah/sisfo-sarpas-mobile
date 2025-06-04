import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  final String token;

  const RiwayatPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, String>> riwayatList = [
      {
        'namaBarang': 'Laptop',
        'tanggalPinjam': '2025-05-20',
        'tanggalKembali': '2025-05-25',
        'status': 'Dikembalikan',
      },
      {
        'namaBarang': 'Proyektor',
        'tanggalPinjam': '2025-05-10',
        'tanggalKembali': '2025-05-15',
        'status': 'Dikembalikan',
      },
      {
        'namaBarang': 'Kamera',
        'tanggalPinjam': '2025-04-01',
        'tanggalKembali': '2025-04-05',
        'status': 'Dikembalikan',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: riwayatList.length,
        itemBuilder: (context, index) {
          final item = riwayatList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(item['namaBarang'] ?? ''),
              subtitle: Text(
                'Pinjam: ${item['tanggalPinjam']} - Kembali: ${item['tanggalKembali']}',
              ),
              trailing: Text(
                item['status'] ?? '',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
