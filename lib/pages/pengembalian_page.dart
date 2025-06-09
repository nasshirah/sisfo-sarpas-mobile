import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/models/peminjaman_model.dart';
import 'package:sisfo_sarpras/models/pengembalian_model.dart';
import 'package:sisfo_sarpras/service/peminjaman_service.dart';

class PengembalianFormPage extends StatefulWidget {
  final String token;
  final int userId;

  const PengembalianFormPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  _PengembalianFormPageState createState() => _PengembalianFormPageState();
}

class _PengembalianFormPageState extends State<PengembalianFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalKembaliController =
      TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  List<Peminjaman> _peminjamanList = [];
  Peminjaman? _selectedPeminjaman;
  bool _isLoading = false;
  bool _isLoadingPeminjaman = true;

  late final PeminjamanService _peminjamanService;

  @override
  void initState() {
    super.initState();
    _peminjamanService = PeminjamanService(token: widget.token);
    _loadUserPeminjaman();
  }

  // Load peminjaman yang belum dikembalikan dan belum diajukan pengembaliannya
  Future<void> _loadUserPeminjaman() async {
    try {
      setState(() => _isLoadingPeminjaman = true);

      // Fetch peminjaman user yang belum dikembalikan
      List<Peminjaman> allPeminjamanList =
          await _peminjamanService.getPeminjamanByUserId(
        userId: widget.userId,
        statusFilter: 'belum_kembali', // atau sesuai dengan status di backend
      );

      // Fetch daftar pengembalian yang sudah diajukan oleh user
      List<Pengembalian> pengembalianList =
          await _peminjamanService.fetchPengembalian(
        userId: widget.userId,
      );

      // Buat set ID peminjaman yang sudah diajukan pengembaliannya
      Set<int> peminjamanIdWithReturn = pengembalianList
          .map((pengembalian) => pengembalian.idPeminjaman)
          .toSet();

      // Filter peminjaman yang belum diajukan pengembaliannya
      List<Peminjaman> availablePeminjamanList = allPeminjamanList
          .where(
              (peminjaman) => !peminjamanIdWithReturn.contains(peminjaman.id))
          .toList();

      // Remove duplicates based on ID to prevent dropdown assertion error
      Map<int, Peminjaman> uniquePeminjaman = {};
      for (var peminjaman in availablePeminjamanList) {
        uniquePeminjaman[peminjaman.id] = peminjaman;
      }

      setState(() {
        _peminjamanList = uniquePeminjaman.values.toList();
        // Reset selected item if it's no longer in the list
        if (_selectedPeminjaman != null &&
            !_peminjamanList.any((p) => p.id == _selectedPeminjaman!.id)) {
          _selectedPeminjaman = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar peminjaman: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingPeminjaman = false);
    }
  }

  Future<void> _submitPengembalian() async {
    if (!_formKey.currentState!.validate() || _selectedPeminjaman == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field yang diperlukan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Store the selected peminjaman info for success dialog
      final submittedPeminjaman = _selectedPeminjaman!;

      // Create pengembalian (status akan diisi oleh admin)
      await _peminjamanService.createPengembalian(
        idPeminjaman: submittedPeminjaman.id,
        tanggalKembali: _tanggalKembaliController.text,
        keterangan: _keteranganController.text.isEmpty
            ? null
            : _keteranganController.text,
      );

      // Clear form and selected item immediately after successful submission
      _tanggalKembaliController.clear();
      _keteranganController.clear();

      setState(() {
        _selectedPeminjaman = null;
        _isLoading = false;
      });

      // Refresh the list to remove the submitted item from dropdown
      await _loadUserPeminjaman();

      // Show success dialog with stored info
      _showSuccessAlert(submittedPeminjaman);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengajukan pengembalian: $e')),
        );
      }
    }
  }

  void _showSuccessAlert(Peminjaman submittedPeminjaman) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop(true);
              }
            });
          }
        });

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Pengajuan Pengembalian Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'ID Peminjaman: ${submittedPeminjaman.id}\nBarang: ${submittedPeminjaman.barang?.namaBarang}\n\nMenunggu persetujuan admin',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_tanggalKembaliController.text.isNotEmpty ||
        _keteranganController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Keluar?'),
              content: const Text(
                  'Data pengembalian belum disimpan. Yakin ingin keluar?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Batal')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Keluar')),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  void dispose() {
    _tanggalKembaliController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Peminjaman
            DropdownButtonFormField<Peminjaman>(
              decoration: const InputDecoration(
                labelText: 'Pilih Peminjaman',
                border: OutlineInputBorder(),
                helperText: 'Pilih peminjaman yang ingin dikembalikan',
              ),
              value: _selectedPeminjaman != null &&
                      _peminjamanList
                          .any((p) => p.id == _selectedPeminjaman!.id)
                  ? _selectedPeminjaman
                  : null,
              items: _peminjamanList.map((peminjaman) {
                return DropdownMenuItem<Peminjaman>(
                  value: peminjaman,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: ${peminjaman.id} - ${peminjaman.barang?.namaBarang ?? "N/A"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Jumlah: ${peminjaman.jumlah} | Tgl Pinjam: ${peminjaman.tanggalPinjam}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeminjaman = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Harap pilih peminjaman' : null,
            ),

            const SizedBox(height: 16),

            // Info Detail Peminjaman yang dipilih
            if (_selectedPeminjaman != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Peminjaman',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('ID Peminjaman: ${_selectedPeminjaman!.id}'),
                    Text(
                        'Barang: ${_selectedPeminjaman!.barang?.namaBarang ?? "N/A"}'),
                    Text('Jumlah Dipinjam: ${_selectedPeminjaman!.jumlah}'),
                    Text(
                        'Tanggal Pinjam: ${_selectedPeminjaman!.tanggalPinjam}'),
                    Text('Status: ${_selectedPeminjaman!.status}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Tanggal Kembali
            TextFormField(
              controller: _tanggalKembaliController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kembali',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final formattedDate =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  _tanggalKembaliController.text = formattedDate;
                }
              },
              validator: (val) => val == null || val.isEmpty
                  ? 'Tanggal kembali harus diisi'
                  : null,
            ),

            const SizedBox(height: 16),

            // Input Keterangan
            TextFormField(
              controller: _keteranganController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (Opsional)',
                border: OutlineInputBorder(),
                helperText: 'Kondisi barang saat dikembalikan, catatan, dll.',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Info tambahan untuk user
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status pengembalian akan dikonfirmasi oleh admin setelah barang diperiksa.',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitPengembalian,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Ajukan Pengembalian',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Pengembalian'),
          backgroundColor: Colors.orange,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoadingPeminjaman
              ? const Center(child: CircularProgressIndicator())
              : _peminjamanList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada peminjaman yang perlu dikembalikan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Semua peminjaman sudah dikembalikan atau sedang dalam proses pengembalian',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _buildForm(),
        ),
      ),
    );
  }
}
