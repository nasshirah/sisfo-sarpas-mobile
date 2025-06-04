class Pengembalian {
  final int id;
  final int idPeminjaman;
  final String tanggalKembali;
  final String? keterangan;
  final String? labelStatus;

  Pengembalian({
    required this.id,
    required this.idPeminjaman,
    required this.tanggalKembali,
    this.keterangan,
    this.labelStatus,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'] ?? 0,
      idPeminjaman: json['id_peminjaman'] ?? 0,
      tanggalKembali: json['tanggal_kembali'] ?? '',
      keterangan: json['keterangan'],
      labelStatus: json['label_status'],
    );
  }
}
