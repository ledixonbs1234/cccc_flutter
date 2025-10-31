class VNPostTransaction {
  final String stt;
  final String trangThai;
  final String hoTen;
  final String maBuuGui;
  final String cuocChuyenPhat;
  final String maThuTuc;
  final String ngayTao;

  VNPostTransaction({
    required this.stt,
    required this.trangThai,
    required this.hoTen,
    required this.maBuuGui,
    required this.cuocChuyenPhat,
    required this.maThuTuc,
    required this.ngayTao,
  });

  // Factory constructor to create from parsed HTML data
  factory VNPostTransaction.fromMap(Map<String, String> data) {
    return VNPostTransaction(
      stt: data['stt'] ?? '',
      trangThai: data['trangThai'] ?? '',
      hoTen: data['hoTen'] ?? '',
      maBuuGui: data['maBuuGui'] ?? '',
      cuocChuyenPhat: data['cuocChuyenPhat'] ?? '',
      maThuTuc: data['maThuTuc'] ?? '',
      ngayTao: data['ngayTao'] ?? '',
    );
  }
}
