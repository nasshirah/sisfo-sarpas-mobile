import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_sarpras/models/peminjaman_model.dart';
import 'package:sisfo_sarpras/models/pengembalian_model.dart';

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

  // Method untuk mengambil peminjaman berdasarkan userId dengan filter status
  Future<List<Peminjaman>> getPeminjamanByUserId({
    required int userId,
    String? statusFilter,
  }) async {
    String url = '$baseUrl/peminjaman?id_user=$userId';
    
    // Tambahkan filter status jika ada
    if (statusFilter != null && statusFilter.isNotEmpty) {
      url += '&status=$statusFilter';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Get Peminjaman by User Response Status: ${response.statusCode}');
    print('Get Peminjaman by User Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Peminjaman.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data peminjaman user: ${response.body}');
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

  // Method untuk membuat pengajuan pengembalian
  Future<Pengembalian> createPengembalian({
    required int idPeminjaman,
    required String tanggalKembali,
    String? keterangan,
  }) async {
    
    final requestData = {
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali': tanggalKembali,
      if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
    };
    
    print('Sending pengembalian request data: $requestData');
    print('URL: $baseUrl/pengembalian');
    
    final response = await http.post(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    print('Pengembalian Response Status: ${response.statusCode}');
    print('Pengembalian Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body)['data'];
      return Pengembalian.fromJson(json);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        print('Pengembalian Error details: $errorData');
        throw Exception('Gagal mengajukan pengembalian: ${errorData['message'] ?? response.body}');
      } catch (e) {
        throw Exception('Gagal mengajukan pengembalian: ${response.body}');
      }
    }
  }

  // Method untuk mengambil data peminjaman berdasarkan ID (opsional, jika diperlukan)
  Future<Peminjaman> getPeminjamanById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Get Peminjaman by ID Response Status: ${response.statusCode}');
    print('Get Peminjaman by ID Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['data'];
      return Peminjaman.fromJson(json);
    } else {
      throw Exception('Gagal mengambil data peminjaman: ${response.body}');
    }
  }

  // Method untuk mengambil daftar pengembalian (opsional, untuk history)
  Future<List<Pengembalian>> fetchPengembalian({int? userId}) async {
    String url = '$baseUrl/pengembalian';
    
    if (userId != null) {
      url += '?id_user=$userId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Fetch Pengembalian Response Status: ${response.statusCode}');
    print('Fetch Pengembalian Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Pengembalian.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data pengembalian: ${response.body}');
    }
  }
}