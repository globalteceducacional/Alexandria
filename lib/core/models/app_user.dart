import '../utils/html_decode.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userImage,
    required this.authId,
    required this.acervoId,
    this.accessToken,
  });

  final int id;
  final String name;
  /// E-mail do leitor em `tbl_users`.
  final String email;
  final String phone;
  final String userImage;
  final String authId;
  final int? acervoId;
  final String? accessToken;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String d(dynamic v) => decodeHtmlEntities(v?.toString() ?? '');

    return AppUser(
      id: int.tryParse('${json['user_id'] ?? json['id'] ?? 0}') ?? 0,
      name: d(json['name']),
      email: json['email']?.toString() ?? json['username']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      userImage: d(json['user_image'] ?? json['userImage'] ?? ''),
      authId: json['auth_id']?.toString() ?? '',
      acervoId: int.tryParse(
        '${json['acervo_id'] ?? json['acervoId'] ?? json['schoolId'] ?? ''}',
      ),
      accessToken: json['accessToken']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_image': userImage,
      'auth_id': authId,
      'acervo_id': acervoId,
      if (accessToken != null) 'accessToken': accessToken,
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? userImage,
    String? accessToken,
    int? acervoId,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      userImage: userImage ?? this.userImage,
      authId: authId,
      acervoId: acervoId ?? this.acervoId,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
