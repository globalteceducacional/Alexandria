import 'dart:convert';

UserLogin userLoginFromJson(String str) => UserLogin.fromJson(json.decode(str));

String userLoginToJson(UserLogin data) => json.encode(data.toJson());

class UserLogin {
  UserLogin({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
        ebookApp: List<EbookApp>.from(
            json["EBOOK_APP"].map((x) => EbookApp.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EBOOK_APP": List<dynamic>.from(ebookApp.map((x) => x.toJson())),
      };
}

class EbookApp {
  EbookApp({
    required this.userId,
    required this.name,
    required this.userImage,
    required this.email,
    required this.phone,
    required this.msg,
    required this.authId,
    required this.success,
  });

  final String userId;
  final String name;
  final String userImage;
  final String email;
  final String phone;
  final String msg;
  final String authId;
  final String success;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        userId: json["user_id"],
        name: json["name"],
        userImage: json["user_image"],
        email: json["email"],
        phone: json["phone"],
        msg: json["MSG"],
        authId: json["auth_id"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "user_image": userImage,
        "email": email,
        "phone": phone,
        "MSG": msg,
        "auth_id": authId,
        "success": success,
      };
}
