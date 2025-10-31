import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  ProfileModel({
    required this.ebookApp,
  });

  final List<EbookApp> ebookApp;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
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
    required this.success,
  });

  final String userId;
  final String name;
  final String userImage;
  final String email;
  final String phone;
  final String success;

  factory EbookApp.fromJson(Map<String, dynamic> json) => EbookApp(
        userId: json["user_id"],
        name: json["name"],
        userImage: json["user_image"],
        email: json["email"],
        phone: json["phone"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "user_image": userImage,
        "email": email,
        "phone": phone,
        "success": success,
      };
}
