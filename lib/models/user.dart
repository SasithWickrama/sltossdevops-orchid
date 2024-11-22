// class User {
//   final String username;
//   final String contractor;
//   final String mobile;

//   User(
//       {required this.contractor, required this.mobile, required this.username});

//   factory User.fromJson(Map<dynamic, dynamic> parsedJson) {
//     return User(
//         username: parsedJson['username'] ?? "",
//         mobile: parsedJson['mobile'] ?? "",
//         contractor: parsedJson['contractor'] ?? "");
//   }

//   Map<dynamic, dynamic> toJson() {
//     return {
//       "mobile": mobile,
//       "contractor": contractor,
//       "username": username,
//     };
//   }
// }
