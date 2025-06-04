import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sisfo_sarpras/models/barang_model.dart';
import 'package:sisfo_sarpras/models/peminjaman_model.dart';
import 'package:sisfo_sarpras/service/barang_service.dart';
import 'package:sisfo_sarpras/service/peminjaman_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeminjamanFormPage extends StatefulWidget {
  final String token;
  final int userId;

  const PeminjamanFormPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  _PeminjamanFormPageState createState() => _PeminjamanFormPageState();
}

class _PeminjamanFormPageState extends State<PeminjamanFormPage> {
  final _formKey = GlobalKey<FormState>();
  List<Barang> _barangList = [];
  Barang? _selectedBarang;
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalPinjamController = TextEditingController();
  bool _isLoading = false;

  late final PeminjamanService _peminjamanService;

  int get _userId => widget.userId;

  @override
  void initState() {
    super.initState();
    _peminjamanService = PeminjamanService(token: widget.token);
    _loadBarang();
  }

  Future<void> _loadBarang() async {
    try {
      List<Barang> barangList = await BarangService(widget.token).fetchBarang();
      setState(() {
        _barangList = barangList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar barang: $e')),
      );
    }
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Timer(const Duration(seconds: 2), () {
          if (mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
            Timer(const Duration(milliseconds: 200), () {
              if (mounted && Navigator.canPop(context)) {
                Navigator.of(context).pop(true);
              }
            });
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Peminjaman Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Barang ${_selectedBarang?.namaBarang} berhasil dipinjam',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedBarang != null &&
        _tanggalPinjamController.text.isNotEmpty) {
      final jumlahPinjam = int.parse(_jumlahController.text);
      if (jumlahPinjam > _selectedBarang!.tersedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jumlah melebihi stok tersedia (${_selectedBarang!.tersedia})')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final peminjaman = await _peminjamanService.createPeminjaman(
          userId: _userId,
          barangId: _selectedBarang!.id,
          tanggalPinjam: _tanggalPinjamController.text,
          jumlah: jumlahPinjam,
        );

        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idPeminjaman', peminjaman.id);
        debugPrint('Saved idPeminjaman: ${peminjaman.id}');

        _showSuccessAlert();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat peminjaman: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_jumlahController.text.isNotEmpty || _tanggalPinjamController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Keluar?'),
              content: const Text('Data peminjaman belum disimpan. Yakin ingin keluar?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Keluar')),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalPinjamController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<Barang>(
              decoration: const InputDecoration(labelText: 'Pilih Barang', border: OutlineInputBorder()),
              items: _barangList.map((b) {
                return DropdownMenuItem(
                  value: b,
                  child: Text('${b.namaBarang} (Tersedia: ${b.tersedia})'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBarang = val),
              validator: (val) => val == null ? 'Harap pilih barang' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jumlahController,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                border: const OutlineInputBorder(),
                helperText: _selectedBarang != null ? 'Max: ${_selectedBarang!.tersedia}' : null,
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Jumlah tidak boleh kosong';
                final n = int.tryParse(val);
                if (n == null || n <= 0) return 'Jumlah harus berupa angka positif';
                if (_selectedBarang != null && n > _selectedBarang!.tersedia) {
                  return 'Jumlah melebihi stok tersedia (${_selectedBarang!.tersedia})';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tanggalPinjamController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Tanggal Pinjam', border: OutlineInputBorder()),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final formattedDate =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  _tanggalPinjamController.text = formattedDate;
                }
              },
              validator: (val) => val == null || val.isEmpty ? 'Tanggal pinjam harus diisi' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Pinjam'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Form Peminjaman')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _barangList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(),
        ),
      ),
    );
  }
}
