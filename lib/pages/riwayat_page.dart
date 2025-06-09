import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfo_sarpras/service/peminjaman_service.dart';
import 'package:sisfo_sarpras/models/peminjaman_model.dart';

class RiwayatPage extends StatefulWidget {
  final String token;
  final int? userId; // Optional parameter

  const RiwayatPage({super.key, required this.token, this.userId});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late PeminjamanService _peminjamanService;
  List<Peminjaman> _riwayatList = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _peminjamanService = PeminjamanService(token: widget.token);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Use passed userId if available, otherwise get from SharedPreferences
      if (widget.userId != null) {
        _userId = widget.userId;
        await _loadRiwayatPeminjaman();
      } else {
        final prefs = await SharedPreferences.getInstance();
        _userId = prefs.getInt('user_id');

        if (_userId != null) {
          await _loadRiwayatPeminjaman();
        } else {
          setState(() {
            _errorMessage = 'User ID tidak ditemukan. Silakan login ulang.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRiwayatPeminjaman() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch all borrowing history for the user (no status filter to get complete history)
      final riwayatData =
          await _peminjamanService.fetchPeminjaman(userId: _userId!);

      setState(() {
        _riwayatList = riwayatData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat riwayat peminjaman: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dikembalikan':
      case 'selesai':
        return Colors.green;
      case 'dipinjam':
      case 'belum_kembali':
        return Colors.orange;
      case 'terlambat':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRiwayatPeminjaman,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRiwayatPeminjaman,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_riwayatList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat peminjaman',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRiwayatPeminjaman,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _riwayatList.length,
        itemBuilder: (context, index) {
          final peminjaman = _riwayatList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                peminjaman.barang?.namaBarang ?? 'Barang tidak diketahui',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Pinjam: ${_formatDate(peminjaman.tanggalPinjam)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event_available,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                          'Kembali: ${_formatDate(peminjaman.tanggalKembali)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.inventory, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Jumlah: ${peminjaman.jumlah}'),
                    ],
                  ),
                ],
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(peminjaman.labelStatus)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(peminjaman.labelStatus),
                    width: 1,
                  ),
                ),
                child: Text(
                  peminjaman.labelStatus,
                  style: TextStyle(
                    color: _getStatusColor(peminjaman.labelStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
