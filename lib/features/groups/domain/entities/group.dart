class Group {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final GroupSettings settings;

  Group({
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
}

class GroupMember {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? nickname;
  final GroupUser user;

  GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.nickname,
    required this.user,
  });
}

class GroupUser {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String verify;
  final DateTime? lastLoginTime;

  GroupUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verify,
    this.lastLoginTime,
  });
}

class GroupSettings {
  final bool allowMembersInvite;
  final bool allowMembersAddList;
  final String defaultSplitMethod;
  final String currency;

  GroupSettings({
    required this.allowMembersInvite,
    required this.allowMembersAddList,
    required this.defaultSplitMethod,
    required this.currency,
  });
}

class GroupsPagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  GroupsPagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}

class GroupsResponse {
  final String message;
  final List<Group> items;
  final GroupsPagination pagination;

  GroupsResponse({
    required this.message,
    required this.items,
    required this.pagination,
  });
}
