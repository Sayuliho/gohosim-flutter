class UserModel {
  final int id;
  final String name;
  final String email;
  final String? wa;

  UserModel({required this.id, required this.name, required this.email, this.wa});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String,
        wa: j['wa'] as String?,
      );

  UserModel copyWith({String? name, String? wa}) =>
      UserModel(id: id, name: name ?? this.name, email: email, wa: wa ?? this.wa);
}
