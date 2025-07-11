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
  final List<GroupBill> bills;
  final List<GroupShoppingList> shoppingLists;

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
    required this.bills,
    required this.shoppingLists,
  });
}

class GroupMember {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? nickname;
  final DateTime? updatedAt;
  final GroupUser user;

  GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.nickname,
    this.updatedAt,
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
  final List<String> blockedUsers;
  final DateTime? lastLoginTime;

  GroupUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verify,
    required this.blockedUsers,
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

class GroupBill {
  final String id;
  final String groupId;
  final String name;
  final String description;
  final double totalAmount;
  final String currency;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupBill({
    required this.id,
    required this.groupId,
    required this.name,
    required this.description,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}

class GroupShoppingList {
  final String id;
  final String groupId;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;
  final String status;
  final double totalEstimatedPrice;
  final double totalActualPrice;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupShoppingList({
    required this.id,
    required this.groupId,
    required this.name,
    required this.description,
    required this.tags,
    this.dueDate,
    required this.status,
    required this.totalEstimatedPrice,
    required this.totalActualPrice,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}

class GroupResponse {
  final String message;
  final Group data;

  GroupResponse({required this.message, required this.data});
}

class CreateGroupRequest {
  final String name;
  final String description;
  final List<GroupMemberInput> members;
  final GroupSettingsInput? settings;

  CreateGroupRequest({
    required this.name,
    required this.description,
    required this.members,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'members': members.map((m) => m.toJson()).toList(),
      if (settings != null) 'settings': settings!.toJson(),
    };
  }
}

class GroupMemberInput {
  final String userId;
  final String? nickname;
  final String? role;

  GroupMemberInput({required this.userId, this.nickname, this.role});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (nickname != null) 'nickname': nickname,
      if (role != null) 'role': role,
    };
  }
}

class GroupSettingsInput {
  final bool? allowMembersInvite;
  final bool? allowMembersAddList;
  final String? defaultSplitMethod;
  final String? currency;

  GroupSettingsInput({
    this.allowMembersInvite,
    this.allowMembersAddList,
    this.defaultSplitMethod,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      if (allowMembersInvite != null) 'allowMembersInvite': allowMembersInvite,
      if (allowMembersAddList != null)
        'allowMembersAddList': allowMembersAddList,
      if (defaultSplitMethod != null) 'defaultSplitMethod': defaultSplitMethod,
      if (currency != null) 'currency': currency,
    };
  }
}

// User search entities
class UserSearchResult {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String verify;

  UserSearchResult({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verify,
  });
}

class UserSearchResponse {
  final String message;
  final List<UserSearchResult> users;

  UserSearchResponse({required this.message, required this.users});
}

// Member management entities
class GroupMembersResponse {
  final String message;
  final List<GroupMember> result;

  GroupMembersResponse({required this.message, required this.result});
}

class AddMembersRequest {
  final List<GroupMemberInput> members;

  AddMembersRequest({required this.members});

  Map<String, dynamic> toJson() {
    return {'members': members.map((m) => m.toJson()).toList()};
  }
}

class UpdateMemberRequest {
  final String? role;
  final String? nickname;

  UpdateMemberRequest({this.role, this.nickname});

  Map<String, dynamic> toJson() {
    return {
      if (role != null) 'role': role,
      if (nickname != null) 'nickname': nickname,
    };
  }
}

class UpdateGroupRequest {
  final String? name;
  final String? description;
  final String? avatarUrl;
  final GroupSettingsInput? settings;

  UpdateGroupRequest({
    this.name,
    this.description,
    this.avatarUrl,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (settings != null) 'settings': settings!.toJson(),
    };
  }
}
