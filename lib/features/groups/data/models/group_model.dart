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
  final List<GroupBillModel> bills;
  final int? pendingBillCount;
  final List<GroupShoppingListModel> shoppingLists;

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
    required this.bills,
    this.pendingBillCount,
    required this.shoppingLists,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isArchived: json['isArchived'] ?? false,
      settings: GroupSettingsModel.fromJson(json['settings'] ?? {}),
      bills:
          (json['bills'] as List<dynamic>?)
              ?.map((bill) => GroupBillModel.fromJson(bill))
              .toList() ??
          [],
      pendingBillCount: json['pendingBillCount'],
      shoppingLists:
          (json['shoppingLists'] as List<dynamic>?)
              ?.map((list) => GroupShoppingListModel.fromJson(list))
              .toList() ??
          [],
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
    bills: bills.map((bill) => bill.toEntity()).toList(),
    shoppingLists: shoppingLists.map((list) => list.toEntity()).toList(),
  );
}

class GroupMemberModel {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? nickname;
  final DateTime? updatedAt;
  final GroupUserModel user;

  GroupMemberModel({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.nickname,
    this.updatedAt,
    required this.user,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] ?? '',
      role: json['role'] ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      nickname: json['nickname'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      user: GroupUserModel.fromJson(json['user'] ?? {}),
    );
  }

  GroupMember toEntity() => GroupMember(
    userId: userId,
    role: role,
    joinedAt: joinedAt,
    nickname: nickname,
    updatedAt: updatedAt,
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
  final List<String> blockedUsers;
  final DateTime? lastLoginTime;

  GroupUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.verify,
    required this.blockedUsers,
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
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
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
    blockedUsers: blockedUsers,
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

class GroupBillModel {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String splitMethod;
  final String paidBy;
  final List<BillParticipantModel> participants;
  final String status;
  final List<BillPaymentModel> payments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupBillModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.splitMethod,
    required this.paidBy,
    required this.participants,
    required this.status,
    required this.payments,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupBillModel.fromJson(Map<String, dynamic> json) {
    return GroupBillModel(
      id: json['_id'] ?? '',
      groupId: json['groupId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      splitMethod: json['splitMethod'] ?? 'equal',
      paidBy: json['paidBy'] ?? '',
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => BillParticipantModel.fromJson(p))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((p) => BillPaymentModel.fromJson(p))
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  GroupBill toEntity() => GroupBill(
    id: id,
    groupId: groupId,
    name: title,
    description: description,
    totalAmount: amount,
    currency: currency,
    status: status,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class BillParticipantModel {
  final String userId;
  final double share;
  final double amountOwed;

  BillParticipantModel({
    required this.userId,
    required this.share,
    required this.amountOwed,
  });

  factory BillParticipantModel.fromJson(Map<String, dynamic> json) {
    return BillParticipantModel(
      userId: json['userId'] ?? '',
      share: (json['share'] ?? 0).toDouble(),
      amountOwed: (json['amountOwed'] ?? 0).toDouble(),
    );
  }
}

class BillPaymentModel {
  final String id;
  final double amount;
  final String paidBy;
  final String paidTo;
  final DateTime date;
  final String method;
  final String notes;
  final String createdBy;
  final DateTime createdAt;

  BillPaymentModel({
    required this.id,
    required this.amount,
    required this.paidBy,
    required this.paidTo,
    required this.date,
    required this.method,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentModel(
      id: json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidBy: json['paidBy'] ?? '',
      paidTo: json['paidTo'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      method: json['method'] ?? '',
      notes: json['notes'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class GroupShoppingListModel {
  final String id;
  final String groupId;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;
  final String status;
  final List<GroupShoppingItemModel> items;
  final double totalEstimatedPrice;
  final double totalActualPrice;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  GroupShoppingListModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.description,
    required this.tags,
    this.dueDate,
    required this.status,
    required this.items,
    required this.totalEstimatedPrice,
    required this.totalActualPrice,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory GroupShoppingListModel.fromJson(Map<String, dynamic> json) {
    return GroupShoppingListModel(
      id: json['_id'] ?? '',
      groupId: json['groupId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: json['status'] ?? 'active',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => GroupShoppingItemModel.fromJson(item))
              .toList() ??
          [],
      totalEstimatedPrice: (json['totalEstimatedPrice'] ?? 0).toDouble(),
      totalActualPrice: (json['totalActualPrice'] ?? 0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  GroupShoppingList toEntity() => GroupShoppingList(
    id: id,
    groupId: groupId,
    name: name,
    description: description,
    tags: tags,
    dueDate: dueDate,
    status: status,
    totalEstimatedPrice: totalEstimatedPrice,
    totalActualPrice: totalActualPrice,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class GroupShoppingItemModel {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final double? estimatedPrice;
  final String? note;
  final String? category;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? purchasedBy;

  GroupShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.estimatedPrice,
    this.note,
    this.category,
    required this.isPurchased,
    this.purchasedAt,
    this.purchasedBy,
  });

  factory GroupShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return GroupShoppingItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      note: json['note'],
      category: json['category'],
      isPurchased: json['isPurchased'] ?? false,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'])
          : null,
      purchasedBy: json['purchasedBy'],
    );
  }
}

// Response models for group creation
class GroupResponseModel {
  final String message;
  final GroupModel data;

  GroupResponseModel({required this.message, required this.data});

  factory GroupResponseModel.fromJson(Map<String, dynamic> json) {
    return GroupResponseModel(
      message: json['message'] ?? '',
      data: GroupModel.fromJson(json['result'] ?? {}),
    );
  }

  GroupResponse toEntity() {
    return GroupResponse(message: message, data: data.toEntity());
  }
}

// Request models for group creation
class CreateGroupRequestModel {
  final String name;
  final String description;
  final List<GroupMemberInputModel> members;
  final GroupSettingsInputModel? settings;

  CreateGroupRequestModel({
    required this.name,
    required this.description,
    required this.members,
    this.settings,
  });

  factory CreateGroupRequestModel.fromEntity(CreateGroupRequest entity) {
    return CreateGroupRequestModel(
      name: entity.name,
      description: entity.description,
      members: entity.members
          .map((m) => GroupMemberInputModel.fromEntity(m))
          .toList(),
      settings: entity.settings != null
          ? GroupSettingsInputModel.fromEntity(entity.settings!)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'members': members.map((m) => m.toJson()).toList(),
      if (settings != null) 'settings': settings!.toJson(),
    };
  }
}

class GroupMemberInputModel {
  final String userId;
  final String? nickname;

  GroupMemberInputModel({required this.userId, this.nickname});

  factory GroupMemberInputModel.fromEntity(GroupMemberInput entity) {
    return GroupMemberInputModel(
      userId: entity.userId,
      nickname: entity.nickname,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, if (nickname != null) 'nickname': nickname};
  }
}

class GroupSettingsInputModel {
  final bool? allowMembersInvite;
  final bool? allowMembersAddList;
  final String? defaultSplitMethod;
  final String? currency;

  GroupSettingsInputModel({
    this.allowMembersInvite,
    this.allowMembersAddList,
    this.defaultSplitMethod,
    this.currency,
  });

  factory GroupSettingsInputModel.fromEntity(GroupSettingsInput entity) {
    return GroupSettingsInputModel(
      allowMembersInvite: entity.allowMembersInvite,
      allowMembersAddList: entity.allowMembersAddList,
      defaultSplitMethod: entity.defaultSplitMethod,
      currency: entity.currency,
    );
  }

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
