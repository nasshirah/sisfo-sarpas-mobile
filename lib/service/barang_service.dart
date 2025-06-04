import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang_model.dart';

class BarangService {
  final String token;
  final String apiUrl = 'http://127.0.0.1:8000/api/barang'; // Ganti jika pakai IP LAN

  BarangService(this.token);

  Future<List<Barang>> fetchBarang() async {
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    // Karena langsung List
    if (decoded is List) {
      return decoded.map((json) => Barang.fromJson(json)).toList();
    } else {
      throw Exception('Format data tidak sesuai: bukan List');
    }
  } else {
    throw Exception('Gagal mengambil data barang: ${response.reasonPhrase}');
  }
}


}
