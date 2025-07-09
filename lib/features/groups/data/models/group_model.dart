import 'package:fairsplit/features/groups/domain/entities/group.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final List<GroupMemberModel> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final GroupSettingsModel settings;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
    required this.settings,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      avatarUrl: json['avatarUrl'],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((member) => GroupMemberModel.fromJson(member))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isArchived: json['isArchived'] ?? false,
      settings: GroupSettingsModel.fromJson(json['settings'] ?? {}),
    );
  }

  Group toEntity() => Group(
    id: id,
    name: name,
    description: description,
    avatarUrl: avatarUrl,
    members: members.map((member) => member.toEntity()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
    isArchived: isArchived,
    settings: settings.toEntity(),
  );
}

class GroupMemberModel {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? nickname;
  final GroupUserModel user;

  GroupMemberModel({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.nickname,
    required this.user,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] ?? '',
      role: json['role'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt']),
      nickname: json['nickname'],
      user: GroupUserModel.fromJson(json['user'] ?? {}),
    );
  }

  GroupMember toEntity() => GroupMember(
    userId: userId,
    role: role,
    joinedAt: joinedAt,
    nickname: nickname,
    user: user.toEntity(),
  );
}

class GroupUserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String verify;
  final DateTime? lastLoginTime;

  GroupUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verify,
    this.lastLoginTime,
  });

  factory GroupUserModel.fromJson(Map<String, dynamic> json) {
    return GroupUserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      verify: json['verify'] ?? '',
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.parse(json['lastLoginTime'])
          : null,
    );
  }

  GroupUser toEntity() => GroupUser(
    id: id,
    username: username,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    verify: verify,
    lastLoginTime: lastLoginTime,
  );
}

class GroupSettingsModel {
  final bool allowMembersInvite;
  final bool allowMembersAddList;
  final String defaultSplitMethod;
  final String currency;

  GroupSettingsModel({
    required this.allowMembersInvite,
    required this.allowMembersAddList,
    required this.defaultSplitMethod,
    required this.currency,
  });

  factory GroupSettingsModel.fromJson(Map<String, dynamic> json) {
    return GroupSettingsModel(
      allowMembersInvite: json['allowMembersInvite'] ?? true,
      allowMembersAddList: json['allowMembersAddList'] ?? true,
      defaultSplitMethod: json['defaultSplitMethod'] ?? 'equal',
      currency: json['currency'] ?? 'VND',
    );
  }

  GroupSettings toEntity() => GroupSettings(
    allowMembersInvite: allowMembersInvite,
    allowMembersAddList: allowMembersAddList,
    defaultSplitMethod: defaultSplitMethod,
    currency: currency,
  );
}

class GroupsPaginationModel {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  GroupsPaginationModel({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory GroupsPaginationModel.fromJson(Map<String, dynamic> json) {
    return GroupsPaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  GroupsPagination toEntity() => GroupsPagination(
    page: page,
    limit: limit,
    totalItems: totalItems,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
    hasPrevPage: hasPrevPage,
  );
}

class GroupsResponseModel {
  final String message;
  final List<GroupModel> items;
  final GroupsPaginationModel pagination;

  GroupsResponseModel({
    required this.message,
    required this.items,
    required this.pagination,
  });

  factory GroupsResponseModel.fromJson(Map<String, dynamic> json) {
    return GroupsResponseModel(
      message: json['message'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => GroupModel.fromJson(item))
              .toList() ??
          [],
      pagination: GroupsPaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  GroupsResponse toEntity() => GroupsResponse(
    message: message,
    items: items.map((item) => item.toEntity()).toList(),
    pagination: pagination.toEntity(),
  );
}
