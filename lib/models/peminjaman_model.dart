import 'barang_model.dart';

class Peminjaman {
  final int id;
  final int idUser;
  final int idBarang;
  final int jumlah;
  final String tanggalPinjam;
  final String? tanggalKembali;
  final String status;
  final String labelStatus;
  final String namaPeminjam;
  final Barang? barang;  // Bisa null jika data barang tidak tersedia

  Peminjaman({
    required this.id,
    required this.idUser,
    required this.idBarang,
    required this.jumlah,
    required this.tanggalPinjam,
    this.tanggalKembali,
    required this.status,
    required this.labelStatus,
    required this.namaPeminjam,
    this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
  return Peminjaman(
    id: int.tryParse(json['id_peminjaman'].toString()) ?? 0,  // <-- sesuaikan ini
    idUser: int.tryParse(json['id_user'].toString()) ?? 0,
    idBarang: int.tryParse(json['id_barang'].toString()) ?? 0,
    jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
    tanggalPinjam: json['tanggal_pinjam'] ?? '',
    tanggalKembali: json['tanggal_kembali'],
    status: json['status'] ?? '',
    labelStatus: json['label_status'] ?? '',
    namaPeminjam: json['nama_peminjam'] ?? '',
    barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
  );
}
}
