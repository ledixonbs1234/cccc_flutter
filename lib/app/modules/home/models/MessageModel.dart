class MessageReceiveModel {
  late String Lenh;
  late String TimeStamp;
  late String DoiTuong;
  late String NameMay;
  MessageReceiveModel(String lenh, String doiTuong,
      {String nameMay = "maychu"}) {
    Lenh = lenh;
    TimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    DoiTuong = doiTuong;
    NameMay = nameMay;
  }

  MessageReceiveModel.fromJson(Map<dynamic, dynamic> json)
      : Lenh = json['Lenh'],
        TimeStamp = json['TimeStamp'],
        DoiTuong = json['DoiTuong'],
        NameMay = json['NameMay'] ?? "";
  Map<dynamic, dynamic> toJson() => {
        'Lenh': Lenh,
        'TimeStamp': TimeStamp,
        'DoiTuong': DoiTuong,
        'NameMay': NameMay
      };
}
