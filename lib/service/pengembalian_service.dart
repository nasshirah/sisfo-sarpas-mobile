import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_sarpras/models/pengembalian_model.dart';

class PengembalianService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final String? token;

  PengembalianService({this.token});

  Future<List<Pengembalian>> fetchPengembalian() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => Pengembalian.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data pengembalian: ${response.body}');
    }
  }

  Future<void> createPengembalian({
    required int idPeminjaman,
    required String tanggalKembali,
    String? keterangan,
    String? labelStatus,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_peminjaman': idPeminjaman,
        'tanggal_kembali': tanggalKembali,
        'keterangan': keterangan,
        'label_status': labelStatus,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menyimpan pengembalian: ${response.body}');
    }
  }
}
