import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';

class ShoppingListModel {
  final String id;
  final String groupId;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;
  final String status;
  final List<ShoppingItemModel> items;
  final double totalEstimatedPrice;
  final double totalActualPrice;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListModel({
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
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['_id'] ?? '',
      groupId: json['groupId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: json['status'] ?? 'active',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ShoppingItemModel.fromJson(item))
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
    );
  }

  ShoppingList toEntity() => ShoppingList(
    id: id,
    groupId: groupId,
    name: name,
    description: description,
    tags: tags,
    dueDate: dueDate,
    status: status,
    items: items.map((item) => item.toEntity()).toList(),
    totalEstimatedPrice: totalEstimatedPrice,
    totalActualPrice: totalActualPrice,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class ShoppingItemModel {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? note;
  final String? category;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? purchasedBy;

  ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.estimatedPrice,
    this.actualPrice,
    this.note,
    this.category,
    required this.isPurchased,
    this.purchasedAt,
    this.purchasedBy,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      actualPrice: json['actualPrice']?.toDouble(),
      note: json['note'],
      category: json['category'],
      isPurchased: json['isPurchased'] ?? false,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'])
          : null,
      purchasedBy: json['purchasedBy'],
    );
  }

  ShoppingItem toEntity() => ShoppingItem(
    id: id,
    name: name,
    quantity: quantity,
    unit: unit,
    estimatedPrice: estimatedPrice,
    actualPrice: actualPrice,
    note: note,
    category: category,
    isPurchased: isPurchased,
    purchasedAt: purchasedAt,
    purchasedBy: purchasedBy,
  );
}

class ShoppingListsResponseModel {
  final String message;
  final int status;
  final List<ShoppingListModel> data;

  ShoppingListsResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ShoppingListsResponseModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListsResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ShoppingListModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  ShoppingListsResponse toEntity() => ShoppingListsResponse(
    message: message,
    status: status,
    data: data.map((item) => item.toEntity()).toList(),
  );
}

class ShoppingListResponseModel {
  final String message;
  final int status;
  final ShoppingListModel data;

  ShoppingListResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ShoppingListResponseModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: ShoppingListModel.fromJson(json['data'] ?? {}),
    );
  }

  ShoppingListResponse toEntity() => ShoppingListResponse(
    message: message,
    status: status,
    data: data.toEntity(),
  );
}

class ShoppingItemResponseModel {
  final String message;
  final int status;
  final ShoppingItemModel data;

  ShoppingItemResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ShoppingItemResponseModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: ShoppingItemModel.fromJson(json['data'] ?? {}),
    );
  }

  ShoppingItemResponse toEntity() => ShoppingItemResponse(
    message: message,
    status: status,
    data: data.toEntity(),
  );
}

class ShoppingItemsResponseModel {
  final String message;
  final int status;
  final List<ShoppingItemModel> data;

  ShoppingItemsResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory ShoppingItemsResponseModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemsResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ShoppingItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  ShoppingItemsResponse toEntity() => ShoppingItemsResponse(
    message: message,
    status: status,
    data: data.map((item) => item.toEntity()).toList(),
  );
}
