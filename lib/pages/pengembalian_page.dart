import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/service/pengembalian_service.dart';

class PengembalianFormPage extends StatefulWidget {
  final String token;
  final int idPeminjaman; // id dari peminjaman yang akan dikembalikan

  const PengembalianFormPage({
    super.key,
    required this.token,
    required this.idPeminjaman,
  });

  @override
  State<PengembalianFormPage> createState() => _PengembalianFormPageState();
}

class _PengembalianFormPageState extends State<PengembalianFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalKembaliController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _selectedLabel;
  bool _isLoading = false;

  late final PengembalianService _pengembalianService;

  @override
  void initState() {
    super.initState();
    _pengembalianService = PengembalianService(token: widget.token);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _pengembalianService.createPengembalian(
        idPeminjaman: widget.idPeminjaman,
        tanggalKembali: _tanggalKembaliController.text,
        keterangan: _keteranganController.text,
        labelStatus: _selectedLabel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengembalian berhasil disimpan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tanggalKembaliController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pengembalian')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tanggalKembaliController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kembali',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _tanggalKembaliController.text =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  }
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Tanggal kembali wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLabel,
                decoration: const InputDecoration(
                  labelText: 'Label Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                  DropdownMenuItem(value: 'menunggu', child: Text('Menunggu')),
                  DropdownMenuItem(value: 'penting', child: Text('Penting')),
                ],
                onChanged: (value) => setState(() => _selectedLabel = value),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Pengembalian'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
