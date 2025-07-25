class CCCDInfo {
  late String Name;
  late String Id;
  late String NgaySinh;
  late String DiaChi;
  late String? NgayLamCCCD = "";
  late String TimeStamp;
  late String gioiTinh;
  String? maBuuGui = ""; // Postal code field

  CCCDInfo(this.Name, this.NgaySinh, this.Id) {
    TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    gioiTinh = "";
    maBuuGui = null;
  }

  fromJson(Map<String, dynamic> json) {
    Name = json['Name'];
    Id = json['Id'];
    NgaySinh = json['NgaySinh'];
    TimeStamp = json['TimeStamp'];
    gioiTinh = json['gioiTinh'] ?? "";
    maBuuGui = json['maBuuGui'];
  }

  Map<dynamic, dynamic> toJsonFull() => {
        'Name': Name,
        'Id': Id,
        'NgaySinh': NgaySinh,
        'TimeStamp': TimeStamp,
        "DiaChi": DiaChi,
        "NgayLamCCCD": NgayLamCCCD ?? "",
        "gioiTinh": gioiTinh,
        "maBuuGui": maBuuGui ?? ""
      };

  Map<dynamic, dynamic> toJson() =>
      {'Name': Name, 'Id': Id, 'NgaySinh': NgaySinh, 'TimeStamp': TimeStamp};

  // Method để tạo chuỗi copy theo format yêu cầu
  String toCopyFormat(int index) {
    return "$index\t${maBuuGui ?? ''}\t$Id\t$Name\t$NgaySinh\t$gioiTinh\t$DiaChi";
  }
}
