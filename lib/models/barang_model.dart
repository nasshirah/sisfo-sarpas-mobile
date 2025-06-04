class Barang {
  final int id;
  final String kodeBarang;
  final String namaBarang;
  final int jumlah;
  final int tersedia;
  final int dipinjam;
  final String kondisi;
  final String lokasi;
  final String status;
  final String keterangan;
  final String? gambarUrl;

  Barang({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.jumlah,
    required this.tersedia,
    required this.dipinjam,
    required this.kondisi,
    required this.lokasi,
    required this.status,
    required this.keterangan,
    this.gambarUrl,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    // Debug: Print raw JSON
    print('🔍 Parsing Barang from JSON:');
    print('Raw JSON: $json');
    
    // Parse ID dengan debugging
    final rawId = json['id_barang'];
    print('Raw ID value: $rawId (type: ${rawId.runtimeType})');
    
    int parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else if (rawId == null) {
      print('⚠️ WARNING: ID is null in JSON!');
      parsedId = 0;
    } else {
      print('⚠️ WARNING: ID has unexpected type: ${rawId.runtimeType}');
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }
    
    print('Parsed ID: $parsedId');
    
    // Parse other fields with debugging
    final namaBarang = json['nama_barang']?.toString() ?? '';
    final kodeBarang = json['kode_barang']?.toString() ?? '';
    final tersedia = int.tryParse(json['tersedia']?.toString() ?? '0') ?? 0;
    
    print('Parsed fields:');
    print('- nama_barang: $namaBarang');
    print('- kode_barang: $kodeBarang');
    print('- tersedia: $tersedia');
    
    final barang = Barang(
      id: parsedId,
      kodeBarang: kodeBarang,
      namaBarang: namaBarang,
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      tersedia: tersedia,
      dipinjam: int.tryParse(json['dipinjam']?.toString() ?? '0') ?? 0,
      kondisi: json['kondisi']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
      gambarUrl: json['gambar']?.toString(),
    );
    
    print('✅ Created Barang: ID=${barang.id}, Name=${barang.namaBarang}');
    print('--- End Barang parsing ---\n');
    
    return barang;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'tersedia': tersedia,
      'dipinjam': dipinjam,
      'kondisi': kondisi,
      'lokasi': lokasi,
      'status': status,
      'keterangan': keterangan,
      'gambar': gambarUrl,
    };
  }

  // Helper method untuk debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'id': id,
      'id_type': id.runtimeType.toString(),
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'tersedia': tersedia,
      'dipinjam': dipinjam,
      'kondisi': kondisi,
      'lokasi': lokasi,
      'status': status,
      'keterangan': keterangan,
      'gambar': gambarUrl,
    };
  }

  @override
  String toString() {
    return 'Barang{id: $id, kodeBarang: $kodeBarang, namaBarang: $namaBarang, tersedia: $tersedia}';
  }

  // Method untuk validasi
  bool get isValid => id > 0 && namaBarang.isNotEmpty;
  
  String get validationMessage {
    if (id <= 0) return 'ID tidak valid (${id})';
    if (namaBarang.isEmpty) return 'Nama barang kosong';
    return 'Valid';
  }
}