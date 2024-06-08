class UserModel {
  final String id;
  final String email;
  final String name;
  final String location;
  final String phoneNumber;
  final String? pic;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      required this.location,
      required this.phoneNumber,
      this.pic});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        location: json['location'],
        phoneNumber: json['phoneNumber'],
        pic: json['pic']);
  }
}
