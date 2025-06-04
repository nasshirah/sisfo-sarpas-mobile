import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_sarpras/models/peminjaman_model.dart';

class PeminjamanService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final String? token;

  PeminjamanService({this.token});

  Future<List<Peminjaman>> fetchPeminjaman({required int userId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman?id_user=$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Fetch Response Status: ${response.statusCode}');
    print('Fetch Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Peminjaman.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data peminjaman: ${response.body}');
    }
  }

  Future<Peminjaman> createPeminjaman({
    required int userId,
    required int barangId,
    required String tanggalPinjam,
    required int jumlah,
  }) async {
    
    // Debug: Print data yang akan dikirim
    final requestData = {
      'id_user': userId,
      'id_barang': barangId,
      'tanggal_pinjam': tanggalPinjam,
      'jumlah': jumlah,
    };
    
    print('Sending request data: $requestData');
    print('URL: $baseUrl/peminjaman');
    
    final response = await http.post(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body)['data'];
      return Peminjaman.fromJson(json);
    } else {
      // Parse error response untuk debugging
      try {
        final errorData = jsonDecode(response.body);
        print('Error details: $errorData');
        throw Exception('Gagal membuat peminjaman: ${errorData['message'] ?? response.body}');
      } catch (e) {
        throw Exception('Gagal membuat peminjaman: ${response.body}');
      }
    }
  }
}