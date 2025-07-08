// Chứa các class đại diện cho thực thể nghiệp vụ (business entities).
// Entities thường giống models, nhưng có thể đơn giản hơn, chỉ chứa các trường cần thiết cho nghiệp vụ.
// Không phụ thuộc vào JSON hay framework nào.
class User {
  final String id;
  final String name;
  User({required this.id, required this.name});
}
