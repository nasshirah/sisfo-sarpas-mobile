import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/models/barang_model.dart';
import 'package:sisfo_sarpras/service/barang_service.dart';

class DataBarangPage extends StatefulWidget {
  final String token;

  const DataBarangPage({super.key, required this.token});

  @override
  State<DataBarangPage> createState() => _DataBarangPageState();
}

class _DataBarangPageState extends State<DataBarangPage> {
  late BarangService _barangService;
  late Future<List<Barang>> _futureBarang;
  List<Barang> _barangList = [];
  List<Barang> _filteredBarangList = [];

  @override
  void initState() {
    super.initState();
    _barangService = BarangService(widget.token);
    _futureBarang = _barangService.fetchBarang().then((data) {
      _barangList = data;
      _filteredBarangList = data;
      return data;
    });
  }

  void _filterBarang(String query) {
    setState(() {
      _filteredBarangList = _barangList
          .where((barang) =>
              barang.namaBarang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Data Barang'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<Barang>>(
        future: _futureBarang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: _filterBarang,
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredBarangList.isEmpty
                    ? const Center(child: Text('Barang tidak ditemukan'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredBarangList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.66,
                        ),
                        itemBuilder: (context, index) {
                          final barang = _filteredBarangList[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: barang.gambarUrl != null &&
                                          barang.gambarUrl!.isNotEmpty
                                      ? Image.network(
                                      
                                          'http://127.0.0.1:8000/storage/${barang.gambarUrl!}',
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 100,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 100,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(Icons.image,
                                                size: 40,
                                                color: Colors.grey),
                                          ),
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            barang.namaBarang,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.indigo,
                                            ),
                                            
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text('', style: TextStyle(fontSize: 12),),
                                          const SizedBox(height: 4),
                                          Text('Jumlah: ${barang.jumlah}',
                                              style:
                                                  const TextStyle(fontSize: 12)),
                                          Text('Tersedia: ${barang.tersedia}',
                                              style:
                                                  const TextStyle(fontSize: 12)),
                                          Text('Dipinjam: ${barang.dipinjam}',
                                              style:
                                                  const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: [
                                              _buildBadge(
                                                  barang.kondisi,
                                                  Colors.blue.shade50,
                                                  Colors.blue),
                                              _buildBadge(
                                                  barang.status,
                                                  Colors.green.shade50,
                                                  Colors.green),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11.5, color: textColor)),
    );
  }
}
