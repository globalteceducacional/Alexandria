import 'dart:convert';

UserRegister userRegisterFromJson(String str) =>
    UserRegister.fromJson(json.decode(str));

String userRegisterToJson(UserRegister data) => json.encode(data.toJson());

class UserRegister {
  UserRegister({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory UserRegister.fromJson(Map<String, dynamic> json) => UserRegister(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.msg,
    required this.success,
    required this.userId,
  });

  final String msg;
  final String success;
  final String userId;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        msg: json["msg"],
        success: json["success"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "success": success,
        "user_id": userId,
      };
}
