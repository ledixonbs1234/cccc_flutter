class CCCDInfo {
  late String Name;
  late String Id;
  late String NgaySinh;
  late String DiaChi;
  late String NgayLamCCCD;
  late String TimeStamp;
  CCCDInfo(this.Name, this.NgaySinh, this.Id) {
    TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
  }
  

  fromJson(Map<String, dynamic> json) {
    Name = json['Name'];
    Id = json['Id'];
    NgaySinh = json['NgaySinh'];
    TimeStamp = json['TimeStamp'];
  }

  Map<dynamic, dynamic> toJsonFull() => {
        'Name': Name,
        'Id': Id,
        'NgaySinh': NgaySinh,
        'TimeStamp': TimeStamp,
        "DiaChi": DiaChi,
        "NgayLamCCCD": NgayLamCCCD
      };

  Map<dynamic, dynamic> toJson() =>
      {'Name': Name, 'Id': Id, 'NgaySinh': NgaySinh, 'TimeStamp': TimeStamp};
}
